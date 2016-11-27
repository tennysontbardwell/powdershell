open OUnit2
open Filemanager
open Filename
open Updater
open Model
open ArrayModel

let ex_jsons = concat (concat current_dir_name "test_files") "example_jsons"

let updater_tests = [
  "load example" >::
    (fun _ ->
      let r = concat ex_jsons "heavy_sand_rules.json" |> read_rules in
      let g = empty_grid (3,3)
        |> set_pixel (1,1) (Some {name="heavy_sand"; color="red"})
        |> next_step r in
      assert_equal ~printer:particle_to_string (particle_at_index g (1,1)) None;
      assert_equal ~printer:particle_to_string (particle_at_index g (1,2))
        (Some {name="heavy_sand"; color="red"}))
]

