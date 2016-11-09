open Model

(* the type of an input *)
type input_t = NoIn | ElemAdd of {elem: string; loc: int * int; radius: int} 
    | Reset of grid_t| Quit

(* [get_inputs] is the current input to the screen *)
val get_inputs : input_t

(* [get_window_size] is the size of the console *)
val get_window_size : int * int

(* [draw_to_screen] takes in a grid_t and draws every element to the screen *)
val draw_to_screen : grid_t -> unit