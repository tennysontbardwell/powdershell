open Model
open Rules
open Yojson.Basic.Util

exception Format_error of string
type file_path_t = string

let parse_inter j : interaction_t = 
  match j |> member "type" |> to_string with
  | "change" ->  Change (
                  j |> member "from" |> to_string,
                  j |> member "to" |> to_string,
                  j |> member "probability" |> to_float
                )
  | _ -> raise
      (Format_error "the interactions could not be parsed for an element")

let parse_move j : move_option_t =
  let to_tuple lst = begin
    match lst with
    | a::b::[] -> (a,b)
    | _ -> raise
      (Format_error "the directions could not be parsed for an element")
  end in
  let prob = j |> member "probability" |> to_float in
  let dirs = j |> member "directions" |> to_list |> List.map to_list
    |> List.map (List.map to_int) |> List.map to_tuple in
  (dirs, prob)

let parse_trans j : transform_t =
  let to_el = j |> member "to" |> to_string in
  let prob = j |> member "probability" |> to_float in
  (to_el, prob)

let parse_grow j : grow_t =
  let to_el = j |> member "to" |> to_string in
  let prob = j |> member "probability" |> to_float in
  (to_el, prob)

let parse_destroy j : destroy_t =
  let to_el = j |> member "from" |> to_string in
  let prob = j |> member "probability" |> to_float in
  (to_el, prob)

let parse_color j = (
  j |> member "r" |> to_int,
  j |> member "g" |> to_int,
  j |> member "b" |> to_int)

let parse_elm j : (name_t * elem_rules_t) = 
  (
    j |> member "name" |> to_string,
    {
      color = j |> member "color" |> parse_color;
      display = j |> member "display" |> to_string;
      lifespan = j |> member "lifespan" |> to_int;
      shimmer = j |> member "shimmer" |> to_int;
      interactions = j |> member "interactions" |> to_list |>
        List.map parse_inter;
      transforms = j |> member "transforms" |> to_list |>
        List.map parse_trans;
      grow = j |> member "grow" |> to_list |>
        List.map parse_grow;
      destroy = j |> member "destroy" |> to_list |>
        List.map parse_destroy;
      decay = j |> member "decay" |> to_float;
      movements = j |> member "movements" |> to_list |> List.map parse_move;
      density = j |> member "density" |> to_int;
      show = j |> member "show" |> to_bool;
    }
  )

let read_rules path =
  let j = Yojson.Basic.from_file path in
  (* let fps = j |> member "fps" |> to_int in *)
  let elements = j |> member "elements" |> to_list in
  elements |> List.map parse_elm |> gen_rules

(*[write_state] writes a grid into a file and places file at path inputted*)
let write_state (gr:ArrayModel.grid_t) path : file_path_t = 
  if path = "" then path else
  let (r,c) = Model.ArrayModel.get_grid_size gr in
  `Assoc 
    [("rows", `Int r); ("cols", `Int c); ("grid", `List (Model.ArrayModel.fold (fun acc (x,y) part_opt -> 
      match part_opt with
      | Some p -> acc@[(`Assoc [("loc", `List [`Int x; `Int y]); ("name", `String p.name)])]
      | None -> acc ) 
    [] gr ))] 
    |> Yojson.Basic.to_file path; path

let parse_name j = 
  j |> member "name" |> to_string

let parse_loc j = 
  j |> member "loc" |> to_list

let to_tuple lst = begin
    match lst with
    | (`Int a)::(`Int b)::[] -> (a,b)
    | _ -> raise
      (Format_error "the directions could not be parsed for an element")
  end

let read_state path =
  try 
    let j = Yojson.Basic.from_file path in
    let grid = j |> member "grid" |> to_list in
    let name_lst = grid |> List.map parse_name in
    let loc_lst = grid |> List.map parse_loc |> List.map (to_tuple) in
    let r = j |> member "rows" |> to_int in
    let c = j |> member "cols" |> to_int in
    let g = j |> member "grid" |> to_list in
    let gr = Model.ArrayModel.empty_grid (r,c) in
    List.iteri (fun i loc -> let part = List.nth name_lst i in 
    Model.ArrayModel.set_pixel loc (Some {name = part}) gr; ()) loc_lst; gr
  with _ -> Model.ArrayModel.empty_grid (10,10)


