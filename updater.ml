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

(* https://stackoverflow.com/questions/21674947/ocaml-deoptionalize-a-list-is-there-a-simpler-way *)
(* This converts an a' option list to a' list, removing the nones *)
let deoptionalize l = 
    List.concat  @@ List.map (function | None -> [] | Some x -> [x]) l

let rec receive_input inp g = match inp with (* SITAR WROTE THIS PLEASE FIX PLEASE *)
| ((ElemAdd i)::t) -> ArrayModel.set_pixel i.loc (Some {name=i.elem; color="red"}) g; receive_input t g
| _ -> g

(* this is [start] after moving 1 in direction [dir] *)
let transform start dir = (fst start + (fst dir), snd start + (snd dir))

(* this is all the leagal [Move_exc]s for a particular location on any grid *)
let get_movements elm_rules loc name = elm_rules.movements
  |> List.map (fun (directions, probability) ->
    directions
    |> List.map (fun dir ->
      Move_exc (name, loc, (transform loc dir), probability)))
  |> List.fold_left (@) []

(* this is a list of [move_t]s for a particular location on the grid *)
let move_options rules grid (x,y) =
  match ArrayModel.particle_at_index grid (x,y) with
  | Some particle -> begin
    let elm_rules = List.assoc particle.name rules in
    let neighbors =
      [x+1,y+1; x+1,y; x+1,y-1; x,y-1; x-1,y-1; x-1, y; x-1,y+1; x,y+1] in
    let get_interaction elm =
      List.filter (fun (Change (x,_,_)) -> x=elm) elm_rules.interactions
      |> (fun x -> match x with | h::t -> Some h | [] -> None) in
    let get_space_interaction (x,y) =
      try
        ArrayModel.particle_at_index grid (x,y)
        >>= (fun x -> x.name |> get_interaction)
        >>= (fun (Change (f,t,p)) -> Change_exc ((x,y), f, t, p) |> return)
      with Invalid_argument _ -> None in
    let interactions = neighbors
      |> List.map return
      |> List.map (fun x -> bind x get_space_interaction)
      |> deoptionalize in
    let moves = get_movements elm_rules (x,y) particle.name in
    interactions @ moves
  end
  | None -> []

let filter_moves (moves : move_t list) : move_t list =
  let prob_filter item p = if Random.float 0. < p then Some item else None in
  let filter (item : move_t) : move_t option = match item with
    | Move_exc (_,_,_,p) | Change_exc (_,_,_,p) -> prob_filter item p in
  moves |> List.map filter |> deoptionalize

let apply_moves grid moves =
  let apply grid move = begin
    match move with
    | Move_exc (name, start, final, _) -> begin
      if ArrayModel.in_grid grid final then
        match (ArrayModel.particle_at_index grid start,
                ArrayModel.particle_at_index grid final) with
        | (Some {name=p_name; color=color}, None) when p_name=name ->
          grid
          |> ArrayModel.set_pixel start None
          |> ArrayModel.set_pixel final (Some {name=name; color=color})
        | _ -> grid
      else grid
    end
    | Change_exc (location, inital, final, _) -> begin
      match ArrayModel.particle_at_index grid location with
      | Some {name=p_name; color=_} when p_name=inital ->
        grid |> ArrayModel.set_pixel location (Some {name=final; color="FUCK"})
      | _ -> grid
    end
  end in
  List.fold_left apply grid moves

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
  apply_moves grid moves

