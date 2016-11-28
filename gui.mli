open Model

type gui_t = LTerm_widget.t

class gui_ob : (unit -> 'a) -> object 
  inherit LTerm_widget.frame
  method get_input : input_t list
  method draw_to_screen : ArrayModel.grid_t -> unit
  method create_matrix : int -> int -> unit
  method get_size : int * int
  method setup : unit
  method load_rules : Rules.rules_t -> unit
  method exit_term : unit
  method handle_buttons : int -> int -> unit
end

(* val new_gui : (unit -> 'a) -> gui_ob *)

(* [get_inputs] is the current input to the screen *)
(* val get_inputs : gui_ob -> input_t option *)
val get_inputs : gui_ob -> input_t list

(* [get_window_size] is the size of the console *)
val get_window_size : gui_ob -> int * int

(* [draw_to_screen] takes in a grid_t and draws every element to the screen *)
val draw_to_screen : ArrayModel.grid_t -> gui_ob -> unit

