open Clock
open Gui
open Updater
open Model
open Rules

type game_t = {
  clk : clock;
  gui : gui_t;
  grid : grid_t;
  rules: rules_t;
}

(* let execute clk state *)
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
  execute game

