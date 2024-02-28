open Model

(* gui_ob should never be initialized outside of Gui.ml
 * The signature exists here to enable type checking *)

(* gui_ob is an extension of the lambda term frame widget class and contains 
 * everything to do with the gui: input, user interface state, displaying grid *)
class gui_ob : (LTerm_widget.modal_frame -> unit -> unit) 
                -> (unit -> unit) -> (unit -> unit) -> object 
  inherit LTerm_widget.frame

  (* returns the input buffer *)
  method get_input : input_t list
  
  (* draws the inputted grid to the screen *)
  method draw_to_screen : ArrayModel.grid_t -> unit

  (* initializes the display grid buffer *)
  method create_matrix : int -> int -> unit

  (* returns int tuple for grid size (NOT SCREEN SIZE) *)
  method get_size : int * int

  (* initializes the whole user interface *)
  method setup : unit

  (* loads the game rules into the gui (for colors and the such) *)
  method load_rules : Rules.rules_t -> unit

  (* boolean for whether or not the game is paused *)
  method is_paused : bool
end

(* Initializes the GUI *)
val setup_gui : Rules.rules_t ->  LTerm.t -> gui_ob -> unit

(* [get_inputs] is the current input to the screen *)
val get_inputs : gui_ob -> input_t list

(* [get_window_size] is the size of the console *)
val get_window_size : gui_ob -> int * int

(* [draw_to_screen] takes in a grid_t and draws every element to the screen *)
val draw_to_screen : ArrayModel.grid_t -> gui_ob -> unit

val is_paused : gui_ob -> bool
