open Model

(* gui_ob is an extension of the lambda term frame widget class and contains 
 * everything to do with the gui: input, user interface state, displaying grid *)
class gui_ob : (LTerm_widget.modal_frame -> unit -> unit) 
                -> (unit -> unit) -> (unit -> 'c) -> object 
  inherit LTerm_widget.frame
  method get_input : input_t list
  method draw_to_screen : ArrayModel.grid_t -> unit
  method create_matrix : int -> int -> unit
  method get_size : int * int
  method setup : unit
  method load_rules : Rules.rules_t -> unit
  method is_paused : bool
  method set_debug : string -> unit
end

val setup_gui : Rules.rules_t ->  LTerm.t -> gui_ob -> unit

(* [get_inputs] is the current input to the screen *)
val get_inputs : gui_ob -> input_t list

(* [get_window_size] is the size of the console *)
val get_window_size : gui_ob -> int * int

(* [draw_to_screen] takes in a grid_t and draws every element to the screen *)
val draw_to_screen : ArrayModel.grid_t -> gui_ob -> unit

val is_paused : gui_ob -> bool
