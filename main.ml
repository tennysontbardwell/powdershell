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

let execute game _ = 
      let inp = game.gui |> get_inputs in receive_input inp game.grid |> next_step game.rules;
      (draw_to_screen game.grid game.gui)

let run rules grid = Lwt_main.run (
  let do_run, push_layer, pop_layer, exit_ =
        LTerm_widget.prepare_simple_run () in
    Lazy.force LTerm.stdout >>= (fun term -> 
    let gui_ob = new Gui.gui_ob exit_ in
    setup_gui rules term gui_ob;
    let (c, r) = get_window_size gui_ob in
    let g = ArrayModel.empty_grid (c, r) in
    let clockspeed = 0.05 in
    let game = {gui = gui_ob; grid = g; rules = rules} in
    Lwt_engine.on_timer clockspeed true (execute game);
    do_run gui_ob ))

let () = run (read_rules "test_files/example_jsons/rules.json") (ArrayModel.empty_grid (1000, 1000))
