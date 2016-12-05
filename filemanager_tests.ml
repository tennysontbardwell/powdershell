open OUnit2
open Filemanager
open Filename
open Rules

let ex_jsons = concat (concat current_dir_name "test_files") "example_jsons"
let rules_json = concat (concat current_dir_name "rules") "default.json"

let load_tests = [
  "load rules" >::
    (fun _ -> rules_json |> read_rules |> ignore);
  "load heavy sand" >::
    (fun _ -> concat ex_jsons "heavy_sand_rules.json" |> read_rules |> ignore);
]

let parse_tests = [
  "check elements are there" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      lookup_rule r "water" |> ignore;
      lookup_rule r "ice" |> ignore;
      lookup_rule r "bhole" |> ignore;
      lookup_rule r "stem" |> ignore;
      lookup_rule r "expl" |> ignore;
      );
  "shimmer" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").shimmer
        2
      );
  "lifespan" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").lifespan
        (-1)
      );
  "display" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").display
        "⣿"
      );
  "color" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").color
        (250,180,0)
      );
  "show" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").show
        true
      );
  "transforms" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").transforms
        []
      );
  "grow" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").grow
        []
      );
  "destroy" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").destroy
        []
      );
  "decay" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").decay
        0.
      );
  "interactions" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").interactions
        [Change ("stem", "sand", 0.05)]
      );
  "movements" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").movements
        [
          [ (0,1) ], 1.0;
          [ (-1,1); (1,1) ], 1.0;
        ]
      );
  "density" >::
    (fun _ ->
      let r = rules_json |> read_rules in
      assert_equal
        (lookup_rule r "sand").density
        8
      );
]

