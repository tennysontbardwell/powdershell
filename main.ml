(* open Clock *)
open Gui
open Lwt
open Updater
open Model
open LTerm_geom
(* open Rules *)
 
type game_t = {
  gui : gui_t;
  grid : grid_t;
  rules: rules_t;
} 

(* type c = {row: int; col: int} *)
(* type s = {rows: int; cols: int} *)

(* (* let execute clk state *)
let rec execute game =
  let clk' = starting_frame game.clk in
  let inputs = get_inputs game.gui in
  let grid' = game.grid |> receive_input inputs |> next_step game.rules in
  let game' = {game with clk=clk'; grid=grid'} in
  draw_to_screen game'.grid;
  block_until game'.clk;
  execute game'

let run rules grid =
  let game = {clk=new_clk; gui=new_gui; grid=grid; rules=rules} in
  execute game *)

let execute = 
  let do_run, push_layer, pop_layer, exit_ =
      LTerm_widget.prepare_simple_run () in
  let gui_ob = new Gui.gui_ob exit_ in
  let (rows, cols) = get_window_size gui_ob in
  let (matrix:grid_t) = (Array.make_matrix rows cols None) in
  (* print_int rows; *)
  ignore (Lwt_engine.on_timer 0.05 true
    (* this is the pipeline where the shit happens *)
      (fun e -> let inp = gui_ob |> get_inputs in receive_input inp matrix |> next_step game.rules;
      (draw_to_screen matrix gui_ob)
  ));
  do_run gui_ob

let run = Lwt_main.run execute

let () = run
