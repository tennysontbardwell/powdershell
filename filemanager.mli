open Yojson.Basic.Util
open Model
open Rules

exception Format_error of string

type file_path_t = string

(* [read_state] reads a json file from a file path and outputs a state *)
val read_state : file_path_t -> Model.ArrayModel.grid_t

(* [read_rules] read a json file and output *)
val read_rules : file_path_t -> Rules.rules_t

(* [write_state] takes a state and outputs a filepath that has stored that 
 * current state *)
val write_state : ArrayModel.grid_t -> file_path_t

