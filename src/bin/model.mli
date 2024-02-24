open Rules

type name_t = string

type color_t = int*int*int

type location_t = int * int

type particle_t = {name: name_t}    

(* the type of an input *)
type input_t =
  ElemAdd of {elem: string; loc: int * int;} | Reset | Quit | Save of string | Load of string

module type Model = sig
    type grid_t
    (* [indices_of_particle] returns a list of locations where this particle type
    * is found *)
    val indices_of_particle : grid_t -> particle_t -> location_t list
    
    (* [particle_at_index] returns Some particle found at this index. If 
     * no particle is found returns None *)
    val particle_at_index : grid_t -> location_t -> particle_t option
    
    (* [empty_grid] takes in a desired grid size in the form (#rows, #cols) 
     * and returns an empty grid. *)
    val empty_grid : int * int -> grid_t   
    
    (* [to_list] returns a list representation of the grid*)
    val to_list : grid_t -> (location_t * particle_t) list 

    (* [get_grid_size] takes in the grid and outputs a tuple of (# rows, # cols)*)
    val get_grid_size : grid_t -> int * int

    (* [set_pixel] takes in location, desired particle and current grid and 
     * outputs the new grid. 
     * If want no particle there, set particle_t option to none.
     * If location is outside of grid, outputs original grid. *)
    val set_pixel : location_t -> particle_t option -> grid_t -> grid_t 

    (* [particle_to_string] if particle is something prints "*" else prints "_"*)
    val particle_to_string : particle_t option -> string

    (* [to_string] prints grid as a string*)
    val to_string : grid_t -> string

    (* [create_grid] creates a grid from a matrix*)
    val create_grid : (location_t * particle_t) array array -> grid_t

    (* [in_grid] returns true if a location is in the grid*)
    val in_grid : grid_t -> location_t -> bool

    (* [deep_copy] copies form first grid to the second grid*)
    val deep_copy : grid_t -> grid_t -> unit

    (* [fold] folds over the grid with any function that has an accumulator
     * location and particle and takes inital state of accumulator and grid to 
     * fold over*)
    val fold : ('a -> location_t -> particle_t option -> 'a) -> 'a -> grid_t -> 'a

    (* [iter] iterates over a grid with a grid and any function that uses a 
     * location and a particle and will output a unit*)
    val iter : (location_t -> particle_t option-> 'a) -> grid_t -> unit
end

module ArrayModel : Model


