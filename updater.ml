open Model
open Rules

(* https://www.cs.cornell.edu/Courses/cs3110/2016fa/l/23-monads/rec.html *)
module Maybe = struct
  type 'a t = 'a option
  let return x = Some x 
  let bind m f = 
    match m with 
      | Some x -> f x 
      | None -> None
  let (>>=) = bind 
end

open Maybe

let assoc_opt a b = try List.assoc a b |> return with | Not_found -> None

type move_t =
  | Move_exc of name_t * location_t * location_t * probability_t
  | Change_exc of location_t * name_t * name_t * probability_t

(* https://stackoverflow.com/questions/243864/what-is-the-ocaml-idiom-equivalent-to-pythons-range-function *)
let rec range i j = if i > j then [] else i :: (range (i+1) j)

(* https://stackoverflow.com/questions/21674947/ocaml-deoptionalize-a-list-is-there-a-simpler-way *)
let deoptionalize l = 
    List.concat  @@ List.map (function | None -> [] | Some x -> [x]) l

let receive_input inputs grid =
  let apply grid input = match input with
  | ElemAdd {elem=name; loc=loc} ->
      grid |> set_pixel loc (Some {name=name; color="FUCK"})
  | Reset -> empty_grid (get_grid_size grid)
  | Quit -> failwith "internal error 42085"
  | Save -> failwith "internal error 09258" in
  List.fold_left apply inputs grid

let transform start dir = (fst start + (fst dir), snd start + (snd dir))

let get_movements elm_rules loc name = elm_rules.movements
  |> List.map (fun (directions, probability) ->
    directions
    |> List.map (fun dir ->
      Move_exc (name, loc, (transform loc dir), probability)))
  |> List.fold_left (@) []

let move_options rules grid (x,y) =
  let particle = match particle_at_index grid (x,y) with
  | Some x -> x
  | None -> failwith "Tennyson fucked up" in
  let elm_rules = List.assoc particle.name rules in
  let neighbors =
    [x+1,y+1; x+1,y; x+1,y-1; x,y-1; x-1,y-1; x-1, y; x-1,y+1; x,y+1] in
  let get_interaction elm =
    List.filter (fun (Change (x,_,_)) -> x=elm) elm_rules.interactions
    |> (fun x -> match x with | h::t -> Some h | [] -> None) in
  let get_space_interaction (x,y) = particle_at_index grid (x,y)
    >>= (fun x -> x.name |> get_interaction)
    >>= (fun (Change (f,t,p)) -> Change_exc ((x,y), f, t, p) |> return) in
  let interactions = neighbors
    |> List.map return
    |> List.map (fun x -> bind x get_space_interaction)
    |> deoptionalize in
  let moves = get_movements elm_rules (x,y) particle.name in
  interactions @ moves

let filter_moves (moves : move_t list) : move_t list =
  let prob_filter item p = if Random.float 0. < p then Some item else None in
  let filter (item : move_t) : move_t option = match item with
    | Move_exc (_,_,_,p) | Change_exc (_,_,_,p) -> prob_filter item p in
  moves |> List.map filter |> deoptionalize

let apply_moves grid moves =
  let apply grid move = begin
    match move with
    | Move_exc (name, start, final, _) -> begin
      match (particle_at_index grid start, particle_at_index grid final) with
      | (Some {name=p_name; color=color}, None) when p_name=name ->
        grid
        |> set_pixel start None
        |> set_pixel final (Some {name=name; color=color})
      | _ -> grid
    end
    | Change_exc (location, inital, final, _) -> begin
      match particle_at_index grid location with
      | Some {name=p_name; color=_} when p_name=inital ->
        grid |> set_pixel location (Some {name=final; color="FUCK"})
      | _ -> grid
    end
  end in
  List.fold_left apply grid moves

let next_step rules grid =
  let x_max,y_max = get_grid_size grid in
  let x_range = range 0 (x_max - 1) in
  let y_range = range 0 (y_max - 1) in
  let xy_range =
    let f y = List.fold_left (fun acc x -> (x,y) :: acc) [] x_range in
    List.fold_left (fun acc y -> f y @ acc) [] y_range in
  let moves =
    List.fold_left (fun acc i -> move_options rules grid i @ acc) [] xy_range 
    |> filter_moves in
  apply_moves grid moves

