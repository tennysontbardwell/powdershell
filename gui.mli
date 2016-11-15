open Model

type gui_t

val new_gui : gui_t

(* [get_inputs] is the current input to the screen *)
val get_inputs : gui_t -> input_t list

(* [get_window_size] is the size of the console *)
val get_window_size : int * int

(* [draw_to_screen] takes in a grid_t and draws every element to the screen *)
val draw_to_screen : grid_t -> unit

