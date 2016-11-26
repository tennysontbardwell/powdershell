open OUnit2
open Filemanager_tests
open Updater_tests

let tests = "test suite" >::: ( []
  @ load_tests
  (* @ updater_tests *)
)

let () = (fun _ -> Filename.concat ex_jsons "rules.json" |> Filemanager.read_rules |> ignore) ()

let _ = run_test_tt_main tests
