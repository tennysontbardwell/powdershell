open Model
open Rules
open Gui

(*[recieve_input] takes in the input and the current grid and outputs the new
 * grid.*)
val receive_input : input_t list -> ArrayModel.grid_t -> ArrayModel.grid_t

(*[next_step] takes in the current game rules and the current game model
 * and outputs the next grid.*)
val next_step : rules_t -> ArrayModel.grid_t -> ArrayModel.grid_t


