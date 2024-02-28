open OUnit2
open Powdershell.Filemanager
open Powdershell.Rules
open Powdershell.Model
open Filename
open ArrayModel
module Filemanager = Powdershell.Filemanager
module Model = Powdershell.Model

let ex_jsons = List.fold_left concat current_dir_name ["resources"; "example_jsons"]
let rules_json = List.fold_left concat current_dir_name [".."; "rules"; "default.json"]

let empty_gr = ArrayModel.empty_grid (3,3)
let empty_gr_300 = ArrayModel.empty_grid (300,300)

let load_tests = [
  "1: load rules" >::
    (fun _ -> rules_json |> read_rules |> ignore);
  
  "2: load heavy sand" >::
    (fun _ -> concat ex_jsons "heavy_sand_rules.json" |> read_rules |> ignore);
  
  "3: write/read empty" >::
    (fun _ -> 
    	Filemanager.write_state empty_gr "test1" |> ignore;
     	assert_equal empty_gr (Filemanager.read_state "test1")
    );
 
  "4: write/read 2" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.set_pixel (1,0) (Some {name= "water"}) empty_gr in
    	Filemanager.write_state gr_mod "test2" |> ignore; 
    	assert_equal gr_mod (Filemanager.read_state "test2" ));
  
  "5: write/read 3" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.set_pixel (299,30) (Some {name= "water"}) empty_gr_300 in 
    	let gr_mod2 = ArrayModel.set_pixel (30,30) (Some {name= "sand"}) gr_mod in 
    	let gr_mod3 = ArrayModel.set_pixel (24,30) (Some {name= "powder"}) gr_mod2 in 
    	Filemanager.write_state gr_mod3 "test3" |> ignore;
    	assert_equal gr_mod3 (Filemanager.read_state "test3" ));

  "6: write/read 4" >::
    (fun _ -> 
    	let gr_mod = Model.ArrayModel.empty_grid (3,3) in
     	ArrayModel.iter (fun (x,y) part_op -> 
     		ArrayModel.set_pixel (x,y) (Some {name = "b"})) gr_mod;
    	Filemanager.write_state gr_mod "test3" |> ignore;
    	assert_equal gr_mod (Filemanager.read_state "test3" ));
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
        [Change ("stem", "sand", 0.05); Change ("bolt", "expd", 1.0)]
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
