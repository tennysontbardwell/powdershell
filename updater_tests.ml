open OUnit2
open Filemanager
open Filename
open Updater
open Model
open ArrayModel
open Helpers

let ex_jsons = concat (concat current_dir_name "test_files") "example_jsons"

let grid_printer grid = String.concat "" ["\n"; to_string grid; "\n"]

let grid_cmp a b = (grid_printer a = grid_printer b)

let updater_tests = [
  "heavy_sand 1 step" >::
    (fun _ ->
      let r = concat ex_jsons "heavy_sand_rules.json" |> read_rules in
      let g = empty_grid (3,3)
        |> set_pixel (1,1) (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
        |> fun g -> set_to_update g [(1,1)]
        |> next_step r in
      assert_equal ~printer:particle_to_string (particle_at_index g (1,1)) None;
      assert_equal ~printer:particle_to_string (particle_at_index g (1,2))
        (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
    );
  "heavy_sand 2 steps" >::
    (fun _ ->
      let r = concat ex_jsons "heavy_sand_rules.json" |> read_rules in
      let g = empty_grid (3,3)
        |> set_pixel (1,1) (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
        |> fun g -> set_to_update g [(1,1)]
        |> next_step r |> next_step r in
      assert_equal ~printer:particle_to_string (particle_at_index g (1,1)) None;
      assert_equal ~printer:particle_to_string (particle_at_index g (1,2))
        (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
    );
  "heavy_sand 3 steps" >::
    (fun _ ->
      let r = concat ex_jsons "heavy_sand_rules.json" |> read_rules in
      let g = empty_grid (3,3)
        |> set_pixel (1,1) (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
        |> fun g -> set_to_update g [(1,1)]
        |> next_step r |> next_step r |> next_step r in
      assert_equal ~printer:particle_to_string (particle_at_index g (1,1)) None;
      assert_equal ~printer:particle_to_string (particle_at_index g (1,2))
        (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
    );
  "heavy_sand 10 steps" >::
    (fun _ ->
      let r = concat ex_jsons "heavy_sand_rules.json" |> read_rules in
      let g = empty_grid (3,15)
        |> set_pixel (1,1) (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
        |> fun g -> set_to_update g [(1,1)]
        |> foldi 10 (next_step r) in
      assert_equal ~printer:particle_to_string (particle_at_index g (1,1)) None;
      assert_equal ~printer:particle_to_string (particle_at_index g (1,11))
        (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
    );
  "heavy_sand stack" >::
    (fun _ ->
      let r = concat ex_jsons "heavy_sand_rules.json" |> read_rules in
      let g = empty_grid (3,3)
        |> set_pixel (1,1) (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
        |> set_pixel (1,0) (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
        |> fun g -> set_to_update g [(1,1);(1,0)]
        |> foldi 2 (next_step r) in
      let expected = empty_grid (3,3)
        |> set_pixel (1,2) (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
        |> set_pixel (1,1) (Some {name="heavy_sand"; display=("a", (100, 100, 100))}) in
      assert_equal ~cmp:grid_cmp ~printer:grid_printer expected g
    );
  "two heavy_sands" >::
    (fun _ ->
      let r = concat ex_jsons "heavy_sand_rules.json" |> read_rules in
      let g = empty_grid (4,4)
        |> set_pixel (3,0) (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
        |> set_pixel (1,0) (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
        |> fun g -> set_to_update g [(3,0);(1,0)]
        |> next_step r |> next_step r |> next_step r in
      assert_equal ~printer:particle_to_string (particle_at_index g (1,0)) None;
      assert_equal ~printer:particle_to_string (particle_at_index g (1,3))
        (Some {name="heavy_sand"; display=("a", (100, 100, 100))});
      assert_equal ~printer:particle_to_string (particle_at_index g (3,3))
        (Some {name="heavy_sand"; display=("a", (100, 100, 100))})
    );
  (* "layer of water" >:: *)
  (*   (fun _ -> *)
  (*     let r = concat ex_jsons "rules.json" |> read_rules in *)
  (*     let w = (Some {name="water"; display=("a", (100, 100, 100))}) in *)
  (*     let g = empty_grid (4,4) *)
  (*       |> set_pixel (0,0) w *)
  (*       |> set_pixel (1,0) w *)
  (*       |> set_pixel (2,0) w *)
  (*       |> set_pixel (3,0) w *)
  (*       |> fun g -> set_to_update g [(0,0);(1,0);(2,0);(3,0)] *)
  (*       |> foldi 50 (next_step r) in *)
  (*     let expected = empty_grid (4,4) *)
  (*       |> set_pixel (0,3) w *)
  (*       |> set_pixel (1,3) w *)
  (*       |> set_pixel (2,3) w *)
  (*       |> set_pixel (3,3) w in *)
  (*     assert_equal ~printer:grid_printer expected g *)
  (*   ); *)
  (* "layer of water one on right top" >:: *)
  (*   (fun _ -> *)
  (*     let r = concat ex_jsons "rules.json" |> read_rules in *)
  (*     let w = (Some {name="water"; display=("a", (100, 100, 100))}) in *)
  (*     let g = empty_grid (4,4) *)
  (*       |> set_pixel (3,2) w *)
  (*       |> set_pixel (1,3) w *)
  (*       |> set_pixel (2,3) w *)
  (*       |> set_pixel (3,3) w *)
  (*       |> foldi 50 (next_step r) in *)
  (*     let expected = empty_grid (4,4) *)
  (*       |> set_pixel (0,3) w *)
  (*       |> set_pixel (1,3) w *)
  (*       |> set_pixel (2,3) w *)
  (*       |> set_pixel (3,3) w in *)
  (*     assert_equal ~printer:grid_printer expected g *)
  (*   ); *)
  (* "layer of water one on left top" >:: *)
  (*   (fun _ -> *)
  (*     let r = concat ex_jsons "rules.json" |> read_rules in *)
  (*     let w = (Some {name="water"; display=("a", (100, 100, 100))}) in *)
  (*     let g = empty_grid (4,4) *)
  (*       |> set_pixel (0,3) w *)
  (*       |> set_pixel (1,3) w *)
  (*       |> set_pixel (2,3) w *)
  (*       |> set_pixel (0,2) w *)
  (*       |> foldi 50 (next_step r) in *)
  (*     let expected = empty_grid (4,4) *)
  (*       |> set_pixel (0,3) w *)
  (*       |> set_pixel (1,3) w *)
  (*       |> set_pixel (2,3) w *)
  (*       |> set_pixel (3,3) w in *)
  (*     assert_equal ~printer:grid_printer expected g *)
  (*   ); *)
  (* "layer of water from wall on left side" >:: *)
  (*   (fun _ -> *)
  (*     let r = concat ex_jsons "rules.json" |> read_rules in *)
  (*     let w = (Some {name="water"; display=("a", (100, 100, 100))}) in *)
  (*     let g = empty_grid (4,4) *)
  (*       |> set_pixel (0,0) (Some {name="water"; display=("a", (100, 100, 100))}) *)
  (*       |> set_pixel (0,1) (Some {name="water"; display=("a", (100, 100, 100))}) *)
  (*       |> set_pixel (0,2) (Some {name="water"; display=("a", (100, 100, 100))}) *)
  (*       |> set_pixel (0,3) (Some {name="water"; display=("a", (100, 100, 100))}) *)
  (*       |> foldi 50 (next_step r) in *)
  (*     let expected = empty_grid (4,4) *)
  (*       |> set_pixel (0,3) w *)
  (*       |> set_pixel (1,3) w *)
  (*       |> set_pixel (2,3) w *)
  (*       |> set_pixel (3,3) w in *)
  (*     assert_equal ~printer:grid_printer expected g *)
  (*   ); *)
  (* "layer of water from wall on right side" >:: *)
  (*   (fun _ -> *)
  (*     let r = concat ex_jsons "rules.json" |> read_rules in *)
  (*     let w = (Some {name="water"; display=("a", (100, 100, 100))}) in *)
  (*     let g = empty_grid (4,4) *)
  (*       |> set_pixel (3,0) w *)
  (*       |> set_pixel (3,1) w *)
  (*       |> set_pixel (3,2) w *)
  (*       |> set_pixel (3,3) w *)
  (*       |> foldi 50 (next_step r) in *)
  (*     let expected = empty_grid (4,4) *)
  (*       |> set_pixel (0,3) w *)
  (*       |> set_pixel (1,3) w *)
  (*       |> set_pixel (2,3) w *)
  (*       |> set_pixel (3,3) w in *)
  (*     assert_equal ~printer:grid_printer expected g *)
  (*   ); *)
]

