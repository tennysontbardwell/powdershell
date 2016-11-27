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

type grid_dimensions = { mutable row: int; mutable col: int}

(* the type of an input *)
type input_t =
  ElemAdd of {elem: string; loc: int * int;} | Reset | Quit | Save


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
    val create_grid : (location_t * particle_t) array array -> grid_t
    val unwrap_grid : grid_t -> (location_t * particle_t) array array
end

(* module HashModule: Model = struct
  	type grid_t = ('_a,'_b) Hashtbl.t 
  	let dim = {	
				row = 0; 
				col = 0;
		  }
	(* [empty_grid] creates the grid of the desired size assuming the 0th 
	row is counted in rows.
 	* Precondition: rows > 0, cols > 0
 	* Postcondition: grid of size rows*cols w*)	
	let empty_grid rows cols= dim.row <- rows; dim.col <- cols; 
		Hashtbl.create (rows*cols)
	(* [get_grid_size] takes in the grid and outputs
 	* a tuple of (width, height) *)
	let get_grid_size grid = (dim.row, dim.col) 
  	let indices_of_particle particle grid = Hasttbl.find_all grid particle  
end *)


module ArrayModel: Model = struct
  	type grid_t = (location_t*particle_t) array array 
    
    let col_counter = ref (-1)
    let next_val =
      fun () ->
      col_counter := (!col_counter) + 1;
      !col_counter

    let row_counter = ref (-1)
    let next_row =
      fun () ->
      row_counter := (!row_counter) + 1;
      !row_counter

    let simple_row rown coln = col_counter := (-1); Array.map 
    (fun x -> ((rown, next_val ()), {name = ""; color = ""})) (Array.make coln 0)

    let empty_grid (rows, cols) : grid_t= row_counter := (-1);
  		Array.map (fun r -> simple_row (next_row ()) cols) (Array.make rows 0)

    let indices_of_particle (grid:grid_t) (particle: particle_t) : location_t list = 
      Array.fold_left (fun acc r -> 
        (Array.fold_left(fun acc_2 c -> 
          if ((snd c) = particle) then (fst c)::acc_2 else acc_2) acc r )) [] grid

    let particle_at_index (grid:grid_t) (location:location_t) : particle_t option = 
      let result = snd (Array.get (Array.get grid (fst location)) (snd location)) in
      match result with
      | {name = ""; color = ""} -> None
      | _ -> Some result
    
    let to_list (grid:grid_t) : particle_t list list = 
       Array.fold_left (fun acc r -> 
        (Array.fold_left(fun acc_2 c -> (snd c)::acc_2) [] r )::acc ) [] grid

    let set_pixel (location:location_t) (particle_opt:particle_t option) (grid:grid_t)
     : grid_t = let particle = match particle_opt with
      | None -> {name = ""; color = ""}
      | Some p -> p
    in Array.set (Array.get grid (fst location))  (snd location) (location,particle);
      grid

    let get_grid_size (grid:grid_t) : int*int = 
    (Array.length grid, Array.length (Array.get grid 0)) 

    let create_grid (grid: (location_t*particle_t) array array) : grid_t = grid

    let unwrap_grid (grid: grid_t) : (location_t*particle_t) array array = grid

    let change_grid_size (r,c) grid = failwith "unimplemented"
      (* let (old_row,old_col) = get_grid_size grid in 
      match (old_row > r, old_col > c) with
      | (true, true) -> Array.map (fun x -> (Array.map (fun y -> Array.get())(Array.make c)) (Array.make r) 
      | (false, true) ->
      | (true, false) ->
      | (false, false) - >*)
end