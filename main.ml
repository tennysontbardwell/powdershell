(* open Clock *)
open Gui
open Lwt
open Updater
open Model
open LTerm_geom
open Rules
open Filemanager

type game_t = {
  gui : gui_ob;
  grid : ArrayModel.grid_t;
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

let execute game _ = 
    (* this is the pipeline where the shit happens *)
      let inp = game.gui |> get_inputs in receive_input inp game.grid |> next_step game.rules;
      (draw_to_screen game.grid game.gui)


let run rules grid = Lwt_main.run (
  let do_run, push_layer, pop_layer, exit_ =
        LTerm_widget.prepare_simple_run () in
    Lazy.force LTerm.stdout >>= (fun term -> 
    let size = LTerm.size term in
    let gui_ob = new Gui.gui_ob exit_ in
    gui_ob#create_matrix (size.cols - 7) (size.rows - 3);
    let g = ArrayModel.empty_grid (size.cols - 7, size.rows - 3) in
    let clockspeed = 0.05 in
    let game = {gui = gui_ob; grid = g; rules = rules} in
    Lwt_engine.on_timer clockspeed true (execute game);
    do_run gui_ob ))

let () = run (read_rules "test_files/example_jsons/rules.json") (ArrayModel.empty_grid (1000, 1000))
