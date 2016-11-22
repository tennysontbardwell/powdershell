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

(* https://stackoverflow.com/questions/243864/what-is-the-ocaml-idiom-equivalent-to-pythons-range-function *)
let rec range i j = if i > j then [] else i :: (range (i+1) j)

let receive_input = failwith "unimplemented"

let move_options rules grid (x,y) =
  let particle = match particle_at_index grid (x,y) with
  | Some x -> x
  | None -> failwith "Tennyson fucked up" in
  let elm_rules = List.assoc particle.name rules in
  let neighbors = List.map (particle_at_index grid)
    [x+1,y+1; x+1,y; x+1,y-1; x,y-1; x-1,y-1; x-1, y; x-1,y+1; x,y+1] in
  let neighbor_names =
    List.map (fun y -> bind y (fun x -> Some x.name)) neighbors in
  let get_interactions elm =
    List.filter (fun (Change (x,_,_)) -> x=elm) elm_rules.interactions in
  (* let interacts = neighbors |> List.map (fun x -> get_interactions x |> bind) in *)
  [(x,y)]

let next_step rules grid =
  let x_max,y_max = get_grid_size grid in
  let x_range = range 0 (x_max - 1) in
  let y_range = range 0 (y_max - 1) in
  let xy_range =
    let f y = List.fold_left (fun acc x -> (x,y) :: acc) [] x_range in
    List.fold_left (fun acc y -> f y @ acc) [] y_range in
  let moves =
    List.fold_left (fun acc i -> move_options rules grid i @ acc) [] xy_range in
  (* moves *)
  failwith "unimplemented"

