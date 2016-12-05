open OUnit2
open Filemanager
open Filename
open Rules
open Model
open ArrayModel

let ex_jsons = concat (concat current_dir_name "test_files") "example_jsons"
let rules_json = concat (concat current_dir_name "rules") "default.json"

let empty_gr = Model.ArrayModel.empty_grid (3,3)
let empty_gr_300 = Model.ArrayModel.empty_grid (300,300)

let load_tests = [
  "1: load rules" >::
    (fun _ -> rules_json |> read_rules |> ignore);
  
  "2: load heavy sand" >::
    (fun _ -> concat ex_jsons "heavy_sand_rules.json" |> read_rules |> ignore);
  
  "3: write_state empty" >::
    (fun _ -> 
     	assert_equal "/tests_build/test1" (Filemanager.write_state empty_gr "/tests_build/test1")
    );
  
  "4: write_state 2" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.set_pixel (1,0) (Some {name= "water"}) empty_gr in 
    	assert_equal "/tests_build/test2" (Filemanager.write_state gr_mod "/tests_build/test2" ));
  
  "5: write_state 3" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.set_pixel (299,30) (Some {name= "water"}) empty_gr_300 in 
    	let gr_mod = ArrayModel.set_pixel (30,30) (Some {name= "sand"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (24,30) (Some {name= "powder"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (60,43) (Some {name= "stuff"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (70,30) (Some {name= "a"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (29,60) (Some {name= "b"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (199,40) (Some {name= "c"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (9,190) (Some {name= "d"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (29,80) (Some {name= "e"}) gr_mod in 
    	assert_equal "/tests_build/test3" (Filemanager.write_state gr_mod "/tests_build/test3" ));

  (* "6: write_state 4" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.iter 
    	(fun (x,y) part_op -> empty_gr.(x).(y) <- ArrayModel.set_pixel (x,y) (Some {name = "b"})) empty_gr in
    	assert_equal "/tests_build/test4" (Filemanager.write_state gr_mod "/tests_build/test4" ));
   *)"7: read_state" >::
    (fun _ -> 
    	assert_equal empty_gr (Filemanager.read_state "/tests_build/test1") )
  ;
  "8: read_state 2" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.set_pixel (1,0) (Some {name= "water"}) empty_gr in 
    	assert_equal gr_mod (Filemanager.read_state "/tests_build/test2") );

  "9: read_state 3" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.set_pixel (299,30) (Some {name= "water"}) empty_gr_300 in 
    	let gr_mod = ArrayModel.set_pixel (30,30) (Some {name= "sand"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (24,30) (Some {name= "powder"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (60,43) (Some {name= "stuff"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (70,30) (Some {name= "a"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (29,60) (Some {name= "b"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (199,40) (Some {name= "c"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (9,190) (Some {name= "d"}) gr_mod in 
    	let gr_mod = ArrayModel.set_pixel (29,80) (Some {name= "e"}) gr_mod in 
    	assert_equal gr_mod (Filemanager.read_state "/tests_build/test3") );

(*   "10: read_state 4" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.iter 
    	(fun (x,y) part_op -> gr.(x).(y) <- ArrayModel.set_pixel (x,y) (Some {name = "b"})) gr in
    	assert_equal gr_mod (Filemanager.read_state "/tests_build/test4") );
 *)]

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
