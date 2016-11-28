open Rules
open Model
open Helpers
open Helpers.Maybe

let assoc_opt a b = try List.assoc a b |> return with | Not_found -> None

let neighbors x y =
  [x+1,y+1; x+1,y; x+1,y-1; x,y-1; x-1,y-1; x-1, y; x-1,y+1; x,y+1]

let neighbors' x y = (x,y) :: neighbors x y

(* represents a single movement of a particle which could be applied in a
 * single step, assuming all of the conditions for each are meet (in actuality
 * they must be checked right before the move is applied *)
type move_t =
  | Move_exc of name_t * location_t * location_t * probability_t
  | Change_exc of location_t * name_t * name_t * probability_t

(* https://stackoverflow.com/questions/21674947/ocaml-deoptionalize-a-list-is-there-a-simpler-way *)
(* This converts an a' option list to a' list, removing the nones *)
let deoptionalize l = 
    List.concat  @@ List.map (function | None -> [] | Some x -> [x]) l

let rec receive_input inp g = match inp with (* SITAR WROTE THIS PLEASE FIX PLEASE *)
| ((ElemAdd i)::t) -> ArrayModel.set_pixel i.loc
  (Some {name=i.elem; display=("a", (100, 100, 100))}) g |> ignore;
  let x,y = i.loc in
  let g' = neighbors' x y @ (ArrayModel.get_to_update g)
  |> ArrayModel.set_to_update g in
  receive_input t g'
| [] -> ArrayModel.get_to_update g |> remove_dup |> ArrayModel.set_to_update g
| _ -> g

(* this is [start] after moving 1 in direction [dir] *)
let transform start dir = (fst start + (fst dir), snd start + (snd dir))

let can_apply_move grid move = match move with
| Move_exc (name, start, final, _) ->
  if ArrayModel.in_grid grid final then
    match (ArrayModel.particle_at_index grid start,
            ArrayModel.particle_at_index grid final) with
    | (Some {name=p_name; display=display}, None) when p_name=name -> true
    | _ -> false
  else false
| Change_exc (location, inital, final, _) ->
  match ArrayModel.particle_at_index grid location with
  | Some {name=p_name; display=_} when p_name=inital ->
      true
  | _ -> false


(* this is all the leagal [Move_exc]s for a particular location on any grid *)
let get_movements elm_rules loc name grid = elm_rules.movements
  |> List.map (fun (directions, probability) ->
    directions
    |> List.map (fun dir ->
      Move_exc (name, loc, (transform loc dir), probability)))
  |> List.fold_left (@) []
  |> List.filter (can_apply_move grid)

(* this is all legal [Change_exc]s for a particular location on any grid *)
let get_changes elm_rules (x,y) name grid =
  (* TODO this doesn't allow multiple changes or something *)
  let get_interaction elm =
    List.filter (fun (Change (x,_,_)) -> x=elm) elm_rules.interactions
    |> (fun x -> match x with | h::t -> Some h | [] -> None) in
  let get_space_interaction (x,y) =
    ArrayModel.particle_at_index grid (x,y)
    >>= (fun x -> x.name |> get_interaction)
    >>= (fun (Change (f,t,p)) -> Change_exc ((x,y), f, t, p) |> return) in
  let interactions = neighbors x y
    |> List.map return
    |> List.map (fun x -> bind x get_space_interaction)
    |> deoptionalize in
  interactions
  |> List.filter (can_apply_move grid)

(* this is a list of [move_t]s for a particular location on the grid *)
let move_options rules grid (x,y) =
  match ArrayModel.particle_at_index grid (x,y) with
  | Some particle -> begin
    let elm_rules = List.assoc particle.name rules in
    let interactions = get_changes elm_rules (x,y) particle.name grid in
    let moves = get_movements elm_rules (x,y) particle.name grid in
    interactions @ moves
  end
  | None -> []

let filter_moves (moves : move_t list) : move_t list =
  let prob_filter item p = if Random.float 0. < p then Some item else None in
  let filter (item : move_t) : move_t option = match item with
    | Move_exc (_,_,_,p) | Change_exc (_,_,_,p) -> prob_filter item p in
  moves |> List.map filter |> deoptionalize

let apply grid move =
  if can_apply_move grid move then
    match move with
    | Move_exc (name, start, final, _) -> begin
      match ArrayModel.particle_at_index grid start with
      | Some {name=p_name; display=display} ->
        grid
        |> ArrayModel.set_pixel start None
        |> ArrayModel.set_pixel final (Some {name=name; display=display})
      | _ -> failwith "Internal Error 20394"
    end
    | Change_exc (location, inital, final, _) -> begin
      match ArrayModel.particle_at_index grid location with
      | Some {name=p_name; display=_} when p_name=inital ->
        grid |> ArrayModel.set_pixel location (Some {name=final; display=("a", (100, 100, 100))})
      | _ -> failwith "Internal Error 4093108"
    end
  else grid

let apply_moves grid moves =
  moves |> shuffle |> List.fold_left apply grid

let get_new_update_list moves : location_t list =
  let f = (fun move -> match move with
    | Move_exc (_,(x1,y1),(x2,y2),_) -> (neighbors' x1 y1) @ (neighbors' x2 y2)
    | Change_exc ((x1,y1),_,_,_) -> (neighbors' x1 y1)
  ) in
  moves |> List.map f |> List.fold_left (@) []
    |> remove_dup

let next_step rules grid =
  let to_update = ArrayModel.get_to_update grid in
  let possible_moves =
    List.fold_left (fun acc i -> move_options rules grid i @ acc) [] to_update
  in
  let choosen_moves = possible_moves |> filter_moves in
  let grid' = apply_moves grid choosen_moves in
  ArrayModel.set_to_update grid' (get_new_update_list choosen_moves)

