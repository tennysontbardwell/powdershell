open Rules

type name_t = string

type color_t = int*int*int

type location_t = int * int

type particle_t = {name: name_t}    

(* type grid_t *)

(* the type of an input *)
type input_t =
  ElemAdd of {elem: string; loc: int * int;} | Reset | Quit | Save

(* [indices_of_particle] returns a list of locations where this particle type
* is found *)
(* val indices_of_particle : grid_t -> particle_t -> location_t list

(* [particle_at_index] returns type of particle found at this index *)
val particle_at_index : grid_t -> location_t -> particle_t option

(* [to_list] returns a list representation of the 
 * display held in the hashtable of pixel locations. Format will be each that 
 * each list will hold all of the particles in that row. There will be a 
 * list of particle lists to represent the entire grid. *)
val to_list : grid_t -> particle_t list list 

[set_pixel] takes in the the current grid, location and desired particle at
 * that location and outputs the new grid
val set_pixel : location_t -> particle_t option -> grid_t -> grid_t 

(* [get_grid_size] takes in the hashtable representing the grid and outputs
 * a tuple of (width, height) *)
val get_grid_size : grid_t -> int * int

(* [change_grid_size] takes in the (width, height) of the desired grid and
 * the current grid and outputs the new grid with the allocations of the old
 * grid copied over. *)
val change_grid_size : int * int -> grid_t -> grid_t 

(* [empty_grid] takes in a desire grid size in the form (width, height) 
 * and returns a hashtable representing that grid. *)
val empty_grid : int * int -> grid_t

 *)

module type Model = sig
    type grid_t
    val indices_of_particle : grid_t -> particle_t -> location_t list
    val particle_at_index : grid_t -> location_t -> particle_t option
    val empty_grid : int * int -> grid_t     
    val to_list : grid_t -> particle_t list list 
    val get_grid_size : grid_t -> int * int
    val change_grid_size : int * int -> grid_t -> grid_t 
    val set_pixel : location_t -> particle_t option -> grid_t -> grid_t 
    val empty_grid : int * int -> grid_t
    val particle_to_string : particle_t option -> string
    val to_string : grid_t -> string
    val create_grid : (location_t*particle_t) array array -> grid_t
    val unwrap_grid : grid_t -> (location_t*particle_t) array array
    val in_grid : grid_t -> location_t -> bool
end

module ArrayModel : Model


