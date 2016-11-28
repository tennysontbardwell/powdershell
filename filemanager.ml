open Model
open Rules
open Yojson.Basic.Util


exception Format_error of string
type file_path_t = string

let parse_inter j : interaction_t =
  Change (
    j |> member "from" |> to_string,
    j |> member "to" |> to_string,
    j |> member "probability" |> to_float
  )

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
      movements = j |> member "movements" |> to_list |> List.map parse_move;
      density = j |> member "density" |> to_int;
    }
  )

(* TODO: finish *)
let read_rules path =
  let j = Yojson.Basic.from_file path in
  (* let fps = j |> member "fps" |> to_int in *)
  let elements = j |> member "elements" |> to_list in
  elements |> List.map parse_elm

(*[handle_loc] helper function for reading location from a json file*)
let handle_loc (j: Yojson.Basic.json list) = match j with
  | [`Int a; `Int b] -> (a,b)
  | _ -> failwith "error"

(*[handle_loc] helper function for reading a string from a json file*)
let handle_str (j: Yojson.Basic.json list) = match j with 
  | [`String a] -> a
  | _ -> failwith "error"

(*[handle_loc] helper function for reading a list from a json file*)
let handle_lst (j: (color_t * Yojson.Basic.json) list) = (* match j with
  | [("loc", `List loc_lst); ("name", `List name_lst); ("color", `List color_lst)] -> 
    (handle_loc loc_lst, {name = (handle_str name_lst); color = (handle_str color_lst)})
  | _ -> failwith "bad json list" *) []
  (* TODO: QUINN FIX THIS SITAR IS DUMB *)

(*[rd_col] helper function for read_state to take in a json column and parse it*)
let rd_col (j:Yojson.Basic.json list) : (location_t*particle_t) list = (* 
  let json_list = (j |> filter_assoc) in 
  List.fold_left (fun acc x -> acc@[handle_lst x]) [] json_list *)
[]
  (* TODO: QUINN FIX THIS SITAR IS DUMB *)

(*[read_state] reads a json file from a path and outputs a grid*)
let read_state (path:file_path_t) : ArrayModel.grid_t = 
  let j = Yojson.Basic.from_file path in
  let json_lst_lst = j |> to_list |> filter_member "row" |> filter_list in
  let json_lst_arr = Array.of_list (List.fold_left 
      (fun acc col -> acc @ [rd_col col]) [] json_lst_lst) in
  Array.fold_left (fun acc_row row -> 
      Array.append acc_row [|(Array.of_list row)|] ) [||] json_lst_arr |> ArrayModel.create_grid

(*[wr_row] converts a row of the grid into json*)
let wr_row (arr:((int*int)* particle_t) array) : Yojson.Basic.json = (* 
  `Assoc [("row", `List ((Array.fold_left 
    (fun acc x -> match x with
      | ((int_1, int_2), particle) -> acc@[(`Assoc
            [("loc", `List [`Int int_1; `Int int_2]); 
             ("name", `List [`String particle.name]);
             ("color", `List [`String particle.color])]
      )]) [] arr) @ [`Null]))] *) `List  []
  (* TODO: QUINN FIX THIS SITAR IS DUMB *)


(*[write_state] writes a grid into a file and places file at "grid.json"*)
let write_state (grid:ArrayModel.grid_t) : file_path_t = 
  let gr = ArrayModel.unwrap_grid grid in  
  (`List (Array.fold_left (fun acc r -> acc@[(wr_row r)]) [] gr) )
  |> Yojson.Basic.to_file "grid.json"; "grid.json"