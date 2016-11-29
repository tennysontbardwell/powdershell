open Clock
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
  clock: clock_t;
} 

let rec execute game _ = 
  (Lwt_unix.sleep (get_speed game.clock)) >>= fun () ->
      game.gui#set_debug ((1. /. (get_speed game.clock) |> string_of_float) ^ " fps");
      let clk = set_start game.clock in
      let inp = game.gui |> get_inputs in
      let grid = receive_input inp game.grid in
      (if not (is_paused game.gui) then
        ignore (next_step game.rules grid) 
      else ());
       draw_to_screen game.grid game.gui;
    execute {game with clock = (end_calc clk)} ()


(* let clock game () =  (Lwt_unix.sleep clockspeed) >>= (fun () -> execute game; clock ()) *)

let run rules grid = Lwt_main.run (
  let do_run, push_layer, pop_layer, exit_ =
        LTerm_widget.prepare_simple_run () in
    Lazy.force LTerm.stdout >>= (fun term -> 
    let gui_ob = new Gui.gui_ob exit_ in
    setup_gui rules term gui_ob;
    let (c, r) = get_window_size gui_ob in
    let g = ArrayModel.empty_grid (c, r) in
    let clk = new_clk in
    let game = {gui = gui_ob; grid = g; rules = rules; clock = clk} in
    async (execute game);
    do_run gui_ob ))

let () = run (read_rules "test_files/example_jsons/rules.json") (ArrayModel.empty_grid (1000, 1000))
