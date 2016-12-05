open OUnit2
open Filemanager
open Filename
open ArrayModel


let ex_jsons = concat (concat current_dir_name "test_files") "example_jsons"
let rules_json = concat (concat current_dir_name "rules") "default.json"

let empty_gr = ArrayModel.empty_grid (3,3)
let empty_gr_300 = ArrayModel.empty_grid (300,300)

let load_tests = [
  "1: load rules" >::
    (fun _ -> rules_json |> read_rules |> ignore);
  
  "2: load heavy sand" >::
    (fun _ -> concat ex_jsons "heavy_sand_rules.json" |> read_rules |> ignore);
  
  "3: write_state empty" >::
    (fun _ -> 
     	assert_equal "/tests_build/test1" (ArrayModel.write_state empty_gr "/tests_build/test1")
    );
  
  "4: write_state 2" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.set_pixel (1,0) (Some {name= "water"}) empty_gr in 
    	assert_equal "/tests_build/test2" (ArrayModel.write_state gr_mod "/tests_build/test2" ));
  
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
    	assert_equal "/tests_build/test3" (ArrayModel.write_state gr_mod "/tests_build/test3" ));

  "6: write_state 4" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.iter 
    	(fun (x,y) part_op -> gr.(x).(y) <- ArrayModel.set_pixel (x,y) (Some {name = "b"})) gr in
    	assert_equal "/tests_build/test4" (ArrayModel.write_state gr_mod "/tests_build/test4" ));
  "7: read_state" >::
    (fun _ -> 
    	assert_equal empty_gr (ArrayModel.read_state "/tests_build/test1") )
  ;
  "8: read_state 2" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.set_pixel (1,0) (Some {name= "water"}) empty_gr in 
    	assert_equal gr_mod (ArrayModel.read_state "/tests_build/test2") );

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
    	assert_equal gr_mod (ArrayModel.read_state "/tests_build/test3") );

  "10: read_state 4" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.iter 
    	(fun (x,y) part_op -> gr.(x).(y) <- ArrayModel.set_pixel (x,y) (Some {name = "b"})) gr in
    	assert_equal gr_mod (ArrayModel.read_state "/tests_build/test4") );
]
