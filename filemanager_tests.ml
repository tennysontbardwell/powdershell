open OUnit2
open Filemanager
open Filename

let ex_jsons = concat (concat current_dir_name "test_files") "example_jsons"
let rules_json = concat (concat current_dir_name "rules") "default.json"

let load_tests = [
  "load rules" >::
    (fun _ -> rules_json |> read_rules |> ignore);
  "load heavy sand" >::
    (fun _ -> concat ex_jsons "heavy_sand_rules.json" |> read_rules |> ignore);
]

