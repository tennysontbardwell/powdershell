open Model

type gui_t = LTerm_widget.t

class gui_ob : (unit -> 'a) -> object 
  inherit LTerm_widget.frame
  method get_input : LTerm_event.t option
  method draw_to_screen : grid_t -> unit
  method create_matrix : int -> int -> unit
end

(* val new_gui : (unit -> 'a) -> gui_ob *)

(* [get_inputs] is the current input to the screen *)
(* val get_inputs : gui_ob -> input_t option *)

(* [get_window_size] is the size of the console *)
(* val get_window_size : int * int *)

(* [draw_to_screen] takes in a grid_t and draws every element to the screen *)
(* val draw_to_screen : grid_t -> gui_ob -> unit *)

