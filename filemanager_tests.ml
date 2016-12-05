open OUnit2
open Filemanager
open Filename
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
  
  "3: write/read empty" >::
    (fun _ -> 
    	Filemanager.write_state empty_gr "test_build/test1" |> ignore;
     	assert_equal empty_gr (Filemanager.read_state "test_build/test1")
    );
 
  "4: write/read 2" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.set_pixel (1,0) (Some {name= "water"}) empty_gr in
    	Filemanager.write_state gr_mod "test_build/test2" |> ignore; 
    	assert_equal gr_mod (Filemanager.read_state "test_build/test2" ));
  
  "5: write/read 3" >::
    (fun _ -> 
    	let gr_mod = ArrayModel.set_pixel (299,30) (Some {name= "water"}) empty_gr_300 in 
    	let gr_mod2 = ArrayModel.set_pixel (30,30) (Some {name= "sand"}) gr_mod in 
    	let gr_mod3 = ArrayModel.set_pixel (24,30) (Some {name= "powder"}) gr_mod2 in 
    	Filemanager.write_state gr_mod3 "test_build/test3" |> ignore;
    	assert_equal gr_mod3 (Filemanager.read_state "test_build/test3" ));

  "6: write/read 4" >::
    (fun _ -> 
    	let gr_mod = Model.ArrayModel.empty_grid (3,3) in
     	ArrayModel.iter (fun (x,y) part_op -> 
     		ArrayModel.set_pixel (x,y) (Some {name = "b"})) gr_mod;
    	Filemanager.write_state gr_mod "test_build/test3" |> ignore;
    	assert_equal gr_mod (Filemanager.read_state "test_build/test3" ));
]
