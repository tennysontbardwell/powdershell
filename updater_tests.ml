open OUnit2
open Filemanager
open Filename
open Updater
open Model

let ex_jsons = concat (concat current_dir_name "test_files") "example_jsons"

let updater_tests = [
  "load example" >::
    (fun _ ->
      let r = concat ex_jsons "heavy_sand.json" |> read_rules in
      let g = empty_grid (3,3)
        |> set_pixel (1,1) Some {name: "heavy_sand"; color"red"}
        |> next_setp r in
      assert_equal (particle_at_index (1,1) g) None;
      assert_equal (particle_at_index (1,2) g)
        (Some {name: "heavy_sand"; color"red"})
]

