open OUnit2
open Filemanager
open Filename
open Model
open ArrayModel

(*
 val indices_of_particle : grid_t -> particle_t -> location_t list
    val particle_at_index : grid_t -> location_t -> particle_t option           
    val empty_grid : int * int -> grid_t                                       2
    val to_list : grid_t -> particle_t list list                               1 
    val get_grid_size : grid_t -> int * int                                    4
    val set_pixel : location_t -> particle_t option -> grid_t -> grid_t        1
    val empty_grid : int * int -> grid_t
    val particle_to_string : particle_t option -> string
    val to_string : grid_t -> string
    val create_grid : (location_t*particle_t) array array -> grid_t
    val unwrap_grid : grid_t -> (location_t*particle_t) array array
    val in_grid : grid_t -> location_t -> bool
    val deep_copy : grid_t -> grid_t -> unit
    val fold : ('a -> location_t -> particle_t -> 'a) -> 'a -> grid_t -> 'a

*)
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
      assert_equal [((0,0),{name = ""}); ((0,1),{name = ""}); ((1,0),{name = ""}); ((1,1),{name = ""})] 
        (Model.ArrayModel.to_list (Model.ArrayModel.empty_grid (2,2))) 
    );
  "8: set_pixel" >::
    (fun _ ->
      let gr = Model.ArrayModel.empty_grid (2,2) in
      let mod_grid = Model.ArrayModel.set_pixel (0,0) (Some {name = "sand"}) gr in
      assert_equal [((0,0),{name = "sand"}); ((0,1),{name = ""}); ((1,0),{name = ""}); ((1,1),{name = ""})]  
        (Model.ArrayModel.to_list mod_grid) 
    );  
  "9: set_pixel 2" >::
    (fun _ ->
      let gr = Model.ArrayModel.empty_grid (2,2) in
      let mod_grid = Model.ArrayModel.set_pixel (0,0) (Some {name = "sand"}) gr in
      let mod_grid_2 = Model.ArrayModel.set_pixel (2,2) (Some {name = "water"}) gr in
      assert_equal [((0,0),{name = "sand"}); ((0,1),{name = ""}); ((1,0),{name = ""}); ((1,1),{name = ""})]  
        (Model.ArrayModel.to_list mod_grid_2) 
    )
]

