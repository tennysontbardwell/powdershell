open OUnit2
open Filemanager
open Filename
open Model
open ArrayModel

let r_sm = [|(0,0),{name= ""}; (0,1),{name = ""}|]
let r_sm2 = [|(1,0),{name= ""}; (1,1),{name = ""}|]
let r_sm3 = [|(2,0),{name= ""}; (2,1),{name = ""}|]

let model_tests = [
  "1: create_grid sq" >::
    (fun _ ->
      assert_equal (Model.ArrayModel.create_grid [|r_sm; r_sm2|]) 
        (Model.ArrayModel.empty_grid (2,2)) 
    );
  "2: create_grid rect" >::
    (fun _ ->
      assert_equal (Model.ArrayModel.create_grid [|r_sm; r_sm2; r_sm3|]) 
        (Model.ArrayModel.empty_grid (3,2)) 
    );
  "3: get_size sq" >::
    (fun _ ->
      assert_equal (2,2) 
        (Model.ArrayModel.get_grid_size (Model.ArrayModel.empty_grid (2,2))) 
    );
  "4: get_size big sq" >::
    (fun _ ->
      assert_equal (5,5) 
        (Model.ArrayModel.get_grid_size (Model.ArrayModel.empty_grid (5,5))) 
    );  
  "5: get_size long rect" >::
    (fun _ ->
      assert_equal (1,5) 
        (Model.ArrayModel.get_grid_size (Model.ArrayModel.empty_grid (1,5))) 
    );
  "6: get_size tall sq" >::
    (fun _ ->
      assert_equal (5,1) 
        (Model.ArrayModel.get_grid_size (Model.ArrayModel.empty_grid (5,1))) 
    );
  "7: to_list empty_grid" >::
    (fun _ ->
      assert_equal [((0,0),{name = ""}); ((0,1),{name = ""}); 
                    ((1,0),{name = ""}); ((1,1),{name = ""})] 
        (Model.ArrayModel.to_list (Model.ArrayModel.empty_grid (2,2))) 
    );
  "8: set_pixel" >::
    (fun _ ->
      let gr = Model.ArrayModel.empty_grid (2,2) in
      let mod_grid = Model.ArrayModel.set_pixel (0,0) (Some {name = "sand"}) gr in
      assert_equal [((0,0),{name = "sand"}); ((0,1),{name = ""}); 
                    ((1,0),{name = ""}); ((1,1),{name = ""})]  
        (Model.ArrayModel.to_list mod_grid) 
    );  
  "9: set_pixel 2 out of bounds" >::
    (fun _ ->
      let gr = Model.ArrayModel.empty_grid (2,2) in
      let mod_grid = Model.ArrayModel.set_pixel (0,0) (Some {name = "sand"}) gr in
      let mod_grid_2 = Model.ArrayModel.set_pixel (2,2) (Some {name = "water"}) gr in
      assert_equal [((0,0),{name = "sand"}); ((0,1),{name = ""}); 
                    ((1,0),{name = ""}); ((1,1),{name = ""})]  
        (Model.ArrayModel.to_list mod_grid_2) 
    );
  "10: set_pixel 3 out of bounds" >::
    (fun _ ->
      let gr = Model.ArrayModel.empty_grid (2,2) in
      let mod_grid = Model.ArrayModel.set_pixel (0,0) (Some {name = "sand"}) gr in
      let mod_grid_2 = Model.ArrayModel.set_pixel ((-1),0) (Some {name = "water"}) mod_grid in
      assert_equal [((0,0),{name = "sand"}); ((0,1),{name = ""}); 
                    ((1,0),{name = ""}); ((1,1),{name = ""})]  
        (Model.ArrayModel.to_list mod_grid_2) 
    );
  "11: set_pixel 4 out of bounds" >::
    (fun _ ->
      let gr = Model.ArrayModel.empty_grid (2,2) in
      let mod_grid = Model.ArrayModel.set_pixel (0,0) (Some {name = "sand"}) gr in
      let mod_grid_2 = Model.ArrayModel.set_pixel (0,(-1)) (Some {name = "water"}) mod_grid in
      assert_equal [((0,0),{name = "sand"}); ((0,1),{name = ""}); 
                    ((1,0),{name = ""}); ((1,1),{name = ""})]  
        (Model.ArrayModel.to_list mod_grid_2) 
    );
  "12: part_at_index" >::
    (fun _ ->
      let gr = Model.ArrayModel.empty_grid (2,2) in
      let mod_grid = Model.ArrayModel.set_pixel (0,0) (Some {name = "sand"}) gr in
      let mod_grid_2 = Model.ArrayModel.set_pixel (1,1) (Some {name = "water"}) mod_grid in
      assert_equal (Some {name = "water"}) (Model.ArrayModel.particle_at_index mod_grid_2 (1,1)) 
    );
  "13: part_at_index 2" >::
    (fun _ ->
      let gr = Model.ArrayModel.empty_grid (2,2) in
      assert_equal None (Model.ArrayModel.particle_at_index gr (1,1)) 
    );
  "14: part_at_index 3" >::
    (fun _ ->
      let gr = Model.ArrayModel.empty_grid (2,2) in
      let mod_grid = Model.ArrayModel.set_pixel (0,0) (Some {name = "sand"}) gr in
      let mod_grid_2 = Model.ArrayModel.set_pixel (1,1) (Some {name = "water"}) mod_grid in
      assert_equal None (Model.ArrayModel.particle_at_index mod_grid_2 (2, 2)) 
    );
  "15: part_at_index 4" >::
    (fun _ ->
      let gr = Model.ArrayModel.empty_grid (2,2) in
      let mod_grid = Model.ArrayModel.set_pixel (0,0) (Some {name = "sand"}) gr in
      let mod_grid_2 = Model.ArrayModel.set_pixel (1,0) (Some {name = "water"}) mod_grid in
      assert_equal (Some {name = "water"}) (Model.ArrayModel.particle_at_index mod_grid_2 (1, 0)) 
    );
  "16: in_grid" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (2,2) in
      assert_equal true (ArrayModel.in_grid gr (1, 0)) 
    );
  "17: in_grid 2" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (2,2) in
      assert_equal false (ArrayModel.in_grid gr (1, 3)) 
    );
  "18: in_grid 3" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (2,2) in
      assert_equal false (ArrayModel.in_grid gr (3, 1)) 
    );
  "19: in_grid 4" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (2,2) in
      assert_equal false (ArrayModel.in_grid gr ((-1), 1)) 
    );
  "20: in_grid 5" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (2,2) in
      assert_equal false (ArrayModel.in_grid gr (1, (-1))) 
    );
  "21: deep_copy" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (2,2) in
      let mod_grid = ArrayModel.set_pixel (0,0) (Some {name = "sand"}) gr in
      let mod_grid_2 = ArrayModel.set_pixel (1,0) (Some {name = "water"}) mod_grid in
      assert_equal mod_grid_2 (ArrayModel.deep_copy mod_grid_2 gr; gr) 
    );
  "22: deep_copy 2" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (5,3) in
      let mod_grid = ArrayModel.set_pixel (1,0) (Some {name = "balloon"}) gr in
      let mod_grid_2 = ArrayModel.set_pixel (6,7) (Some {name = "water"}) mod_grid in
      assert_equal mod_grid_2 (ArrayModel.deep_copy mod_grid_2 gr; gr) 
    );
  "23: deep_copy 3" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (5,3) in
      let mod_grid = ArrayModel.set_pixel (1,0) (Some {name = "balloon"}) gr in
      let mod_grid_2 = ArrayModel.set_pixel (6,7) (Some {name = "water"}) mod_grid in
      assert_equal mod_grid_2 (ArrayModel.deep_copy mod_grid_2 mod_grid; mod_grid) 
    );
  "24: ind_of_part" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (5,3) in
      let mod_grid = ArrayModel.set_pixel (1,0) (Some {name = "balloon"}) gr in
      let mod_grid_2 = ArrayModel.set_pixel (3,2) (Some {name = "balloon"}) mod_grid in
      assert_equal [(3,2);(1,0)] (ArrayModel.indices_of_particle mod_grid_2 {name = "balloon"}) 
    );
  "25: ind_of_part 2" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (5,3) in
      let mod_grid = ArrayModel.set_pixel (1,0) (Some {name = "balloon"}) gr in
      let mod_grid_2 = ArrayModel.set_pixel (3,2) (Some {name = "balloon"}) mod_grid in
      assert_equal [] (ArrayModel.indices_of_particle mod_grid_2 {name = "song"}) 
    );
  "25: ind_of_part 3" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (5,3) in
      let mod_grid = ArrayModel.set_pixel (1,0) (Some {name = "balloon"}) gr in
      let mod_grid_2 = ArrayModel.set_pixel (3,2) (Some {name = "balloon"}) mod_grid in
      assert_equal [] (ArrayModel.indices_of_particle mod_grid_2 {name = "song"}) 
    );
  "26: fold" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (5,3) in
      let mod_grid = ArrayModel.set_pixel (1,0) (Some {name = "balloon"}) gr in
      let mod_grid_2 = ArrayModel.set_pixel (3,2) (Some {name = "water"}) mod_grid in
        assert_equal [{name = "balloon"}; {name = "water"}]
        (ArrayModel.fold (fun acc loc part -> match part with
        | Some part -> acc@[part] 
        | None -> acc) [] mod_grid_2) 
    );  
  "27: fold 2" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (5,3) in
      let mod_grid = ArrayModel.set_pixel (1,0) (Some {name = "balloon"}) gr in
      let mod_grid_2 = ArrayModel.set_pixel (3,2) (Some {name = "water"}) mod_grid in
        assert_equal [|{name = "balloon"}; {name = "water"}|]
        (ArrayModel.fold (fun acc loc part -> match part with
        | Some part -> Array.append acc [|part|] 
        | None -> acc) [||] mod_grid_2) 
    );  
  "28: iter" >::
    (fun _ ->
      let gr = ArrayModel.empty_grid (5,3) in
      let mod_grid = ArrayModel.set_pixel (1,0) (Some {name = "balloon"}) gr in
      let mod_grid_2 = ArrayModel.set_pixel (3,2) (Some {name = "water"}) mod_grid in
        assert_equal ()
        (ArrayModel.iter (fun loc part -> ArrayModel.set_pixel loc part mod_grid_2; () ) mod_grid_2) 
    ); 
]