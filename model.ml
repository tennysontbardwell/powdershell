(* type name_t = unit *)
(* type color_t = unit *)
(* type location_t = unit *)
(* type particle_t = unit *)
(* type grid_t = unit *)
(* type input_t = unit *)

type name_t = string

type color_t = string

type location_t = int * int

type particle_t = {name: name_t; color : color_t}   

type grid_t

(* the type of an input *)
type input_t =
  ElemAdd of {elem: string; loc: int * int;} | Reset | Quit | Save


let indices_of_particle = failwith "unimplemented"
let particle_at_index = failwith "unimplemented"
let to_list = failwith "unimplemented"
let set_pixel = failwith "unimplemented"
let get_grid_size = failwith "unimplemented"
let change_grid_size = failwith "unimplemented"
let empty_grid = failwith "unimplemented"

