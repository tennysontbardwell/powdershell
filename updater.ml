open Rules
open Model
open Helpers
open Helpers.Maybe

let assoc_opt a b = try List.assoc a b |> return with | Not_found -> None

(* represents a single movement of a particle which could be applied in a
 * single step, assuming all of the conditions for each are meet (in actuality
 * they must be checked right before the move is applied *)
type move_t =
  | Move_exc of name_t * location_t * location_t * probability_t
  | Change_exc of location_t * name_t * name_t * probability_t
  | Add_exc of location_t * name_t * probability_t
  | Destroy_exc of location_t * name_t * probability_t

(* https://stackoverflow.com/questions/21674947/ocaml-deoptionalize-a-list-is-there-a-simpler-way *)
(* This converts an a' option list to a' list, removing the nones *)
let deoptionalize l = 
    List.concat @@ List.map (function | None -> [] | Some x -> [x]) l

let rec receive_input inp g = match inp with
| Reset::t -> let empty = ArrayModel.empty_grid (ArrayModel.get_grid_size g) in
    ArrayModel.deep_copy empty g; receive_input t g
| (Save file)::t -> ignore (Filemanager.write_state g ("saves/" ^ file));
      receive_input t g
| (Load file)::t -> let s = Filemanager.read_state ("saves/" ^ file) in
      ArrayModel.deep_copy s g; receive_input t g
| ((ElemAdd i)::t) -> (if i.elem = "erase" then 
    ignore (ArrayModel.set_pixel i.loc None g)
    else let npix = Some {name=i.elem} in
    if ArrayModel.particle_at_index g i.loc = None then
    ArrayModel.set_pixel i.loc npix g |> ignore); receive_input t g
| _ -> g

(* this is [start] after moving 1 in direction [dir] *)
let translate start dir = (fst start + (fst dir), snd start + (snd dir))

let can_apply_move grid rules move = match move with
| Move_exc (name, start, final, _) ->
  if ArrayModel.in_grid grid final then
    match (ArrayModel.particle_at_index grid start,
            ArrayModel.particle_at_index grid final) with
    | (Some {name=p_name}, None) when p_name=name -> true
    | (Some {name=a_name}, Some {name=b_name}) when a_name=name ->
        (lookup_rule rules a_name).density > (lookup_rule rules b_name).density
    | _ -> false
  else false
| Change_exc (location, inital, final, _) -> begin
    match ArrayModel.particle_at_index grid location with
    | Some {name=p_name} when p_name=inital ->
        true
    | _ -> false
  end
| Add_exc (location, _, _) ->
  if ArrayModel.in_grid grid location then
    match ArrayModel.particle_at_index grid location with
    | Some _ -> false
    | None -> true
  else false
| Destroy_exc (location, name, _) -> begin
    match ArrayModel.particle_at_index grid location with
    | Some {name=a_name} when a_name=name -> true
    | _ -> false
  end

(* this is all the legal [Move_exc]s for a particular location on any grid *)
let get_movements elm_rules rules loc name grid = elm_rules.movements
  |> List.map (fun (directions, probability) ->
    directions
    |> List.map (fun dir ->
      Move_exc (name, loc, (translate loc dir), probability)))
  |> List.fold_left (@) []
  |> List.filter (can_apply_move grid rules)

let neighbors x y =
  [x+1,y+1; x+1,y; x+1,y-1; x,y-1; x-1,y-1; x-1, y; x-1,y+1; x,y+1]

(* this is all legal [Change_exc]s for a particular location on any grid *)
let get_changes elm_rules rules (x,y) name grid =
  let get_interactions elm =
    List.filter (fun (Change (x,_,_)) -> x=elm) elm_rules.interactions in
  let get_space_interaction (x,y) =
    ArrayModel.particle_at_index grid (x,y)
    >>= (fun x -> Some (get_interactions x.name))
    >>= fun i ->
      Some (List.map (fun (Change (f,t,p)) -> Change_exc ((x,y), f, t, p)) i)
  in
  let interactions = neighbors x y
    |> List.map return  (* TODO: tennysone, rewrite me *)
    |> List.map (fun x -> bind x get_space_interaction)
    |> deoptionalize
    |> List.fold_left (@) [] in
  interactions |> List.filter (can_apply_move grid rules)

let get_grows elm_rules (x,y) name grid =
  if List.length elm_rules.grow > 0 then
    let get_add_exc loc =
      ArrayModel.particle_at_index grid loc
      |> (fun i -> match i with
        | Some _ -> []
        | None -> List.map
          (fun (elm, prob) -> Add_exc (loc, elm, prob)) elm_rules.grow ) in
    neighbors x y |> List.map get_add_exc |> List.fold_left (@) []
  else []

let get_destroy elm_rules (x,y) name grid =
  if List.length elm_rules.destroy > 0 then
    let get_add_exc loc =
      ArrayModel.particle_at_index grid loc
      |> (fun i -> match i with
        | None -> []
        | Some {name=a_name} ->
            List.filter (fun (name, prob) -> name = a_name) elm_rules.destroy
            |> List.map (fun (elm, prob) -> Destroy_exc (loc, elm, prob)))
    in
    neighbors x y |> List.map get_add_exc |> List.fold_left (@) []
  else []

let get_decays elm_rules loc name grid =
  [Destroy_exc (loc, name, elm_rules.decay)]

let get_transforms elm_rules loc name =
  List.map (fun (n, p) -> Change_exc (loc, name, n, p)) elm_rules.transforms

(* this is a list of [move_t]s for a particular location on the grid *)
let move_options rules grid (x,y) =
  match ArrayModel.particle_at_index grid (x,y) with
  | Some particle -> begin
    let elm_rules = lookup_rule rules particle.name in
    let interactions = get_changes elm_rules rules (x,y) particle.name grid in
    let transforms = get_transforms elm_rules (x,y) particle.name in
    let moves = get_movements elm_rules rules (x,y) particle.name grid in
    let grows = get_grows elm_rules (x,y) particle.name grid in
    let decays = get_decays elm_rules (x,y) particle.name grid in
    let destroy = get_destroy elm_rules (x,y) particle.name grid in
    interactions @ transforms @ moves @ grows @ decays @ destroy
  end
  | None -> []

let filter_moves (moves : move_t list) : move_t list =
  let prob_filter item p = if Random.float 1. < p then Some item else None in
  let filter (item : move_t) : move_t option = match item with
    | Move_exc (_,_,_,p) | Change_exc (_,_,_,p) | Add_exc (_,_,p)
    | Destroy_exc (_,_,p) -> prob_filter item p in
  moves |> List.map filter |> deoptionalize

let apply rules grid move =
  if can_apply_move grid rules move then
    match move with
    | Move_exc (name, start, final, _) -> begin
      match (ArrayModel.particle_at_index grid start,
        ArrayModel.particle_at_index grid final) with
      | a,b -> grid
        |> ArrayModel.set_pixel start b
        |> ArrayModel.set_pixel final a
    end
    | Change_exc (location, inital, final, _) -> begin
      match ArrayModel.particle_at_index grid location with
      | Some {name=p_name} when p_name=inital ->
        grid |> ArrayModel.set_pixel location (Some {name=final})
      | _ -> failwith "Internal Error 4093108"
    end
    | Add_exc (loc, name, _) -> ArrayModel.set_pixel loc (Some {name=name}) grid
    | Destroy_exc (loc, _, _) -> ArrayModel.set_pixel loc None grid
  else grid

let apply_moves grid rules moves =
  moves |> shuffle |> List.fold_left (apply rules) grid

let next_step rules grid =
  let x_max,y_max = ArrayModel.get_grid_size grid in
  let x_range = range 0 (x_max - 1) in
  let y_range = range 0 (y_max - 1) in
  let xy_range =
    let f y = List.fold_left (fun acc x -> (x,y) :: acc) [] x_range in
    List.fold_left (fun acc y -> f y @ acc) [] y_range in
  let moves =
    List.fold_left (fun acc i -> move_options rules grid i @ acc) [] xy_range 
    |> filter_moves in
  apply_moves grid rules moves

