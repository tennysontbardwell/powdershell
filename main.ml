(* open Clock *)
open Gui
open Lwt
(* open Updater *)
open Model
(* open Rules *)
(* 
type game_t = {
  clk : clock;
  gui : gui_t;
  grid : grid_t;
  rules: rules_t;
} *)

type c = {row: int; col: int}

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

let handle_input matrix inp = 
 match inp with 
  | Some (LTerm_event.Mouse {row = r; col = c}) ->
  (* print_endline "mouse";  *)
    matrix.(r).(c) <- 1
  | None -> ()
  (* | Some x -> x |> LTerm_event.to_string |> print_endline *)
  | _ -> ()

let execute = 
  let (matrix:grid_t) = (Array.make_matrix 100 100 0) in
  let do_run, push_layer, pop_layer, exit_ =
      LTerm_widget.prepare_simple_run () in
  let gui_ob = new Gui.gui_ob exit_ in
  
  Lazy.force LTerm.stdout 
  >>= fun term ->
  LTerm.enable_mouse term
  >>= fun () ->
  LTerm.enter_raw_mode term;

    ignore (Lwt_engine.on_timer 0.05 true
              (fun e -> gui_ob#get_input |> handle_input matrix;
                (gui_ob#draw_to_screen matrix )));
    do_run gui_ob

let run = Lwt_main.run execute

let () = run
