open Powdershell.Gui
open Lwt
open Powdershell.Updater
open Powdershell.Model
open LTerm_geom
open Powdershell.Rules
open Powdershell.Filemanager

(* type of game that is passed through the game cycle *)
type game_t = {
  gui : gui_ob;
  grid : ArrayModel.grid_t;
  rules: rules_t;
}

(* recursive game loop. waits 0.04 seconds after every frame to maintain fps *)
let rec execute game _ = 
  let inp = game.gui |> get_inputs in
  let grid = receive_input inp game.grid in
  (if not (is_paused game.gui) then
    return ({game with grid = next_step game.rules grid}) 
  else return game) 
  >>= fun game -> draw_to_screen game.grid game.gui |> return
  >>= fun _ -> Lwt_unix.sleep 0.04 >>= execute game

(* run this to execute the game *)
let run rules = Lwt_main.run (
  let do_run, push_layer, pop_layer, exit_ =
      LTerm_widget.prepare_simple_run () in
  Lazy.force LTerm.stdout >>= (fun term -> 
    let gui_ob = new Powdershell.Gui.gui_ob push_layer pop_layer exit_ in
    setup_gui rules term gui_ob;
    let (c, r) = get_window_size gui_ob in
    let g = ArrayModel.empty_grid (c, r) in
    let game = {gui = gui_ob; grid = g; rules = rules} in
    async (execute game);
    do_run gui_ob ))

let () = run (read_rules "rules/default.json")
