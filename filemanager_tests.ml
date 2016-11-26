open OUnit2
open Filemanager
open Filename

let ex_jsons = concat (concat current_dir_name "test_files") "example_jsons"

let load_tests = [
  "load example" >::
    (fun _ -> concat ex_jsons "rules.json" |> read_rules |> ignore)
]

