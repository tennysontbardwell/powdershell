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

let parse_elm j : (name_t * elem_rules_t) = 
  (
    j |> member "name" |> to_string,
    {
      interactions = j |> member "interactions" |> to_list |>
        List.map parse_inter;
      movements = j |> member "movements" |> to_list |> List.map parse_move;
      density = j |> member "density" |> to_int;
    }
  )

let read_rules path =
  let j = Yojson.Basic.from_file path in
  (* let fps = j |> member "fps" |> to_int in *)
  let elements = j |> member "elements" |> to_list in
  elements |> List.map parse_elm

(*write state which is type array array to json list list*)
let read_state j :  = failwith "unimplemented" 
let write_state _ = failwith "unimplemented"

