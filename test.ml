open OUnit2
open Filemanager_tests

let tests = "test suite" >::: ( []
  @ load_tests
)

let _ = run_test_tt_main tests
