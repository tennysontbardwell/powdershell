(* type name_t = unit *)
(* type color_t = unit *)
(* type location_t = unit *)
(* type particle_t = unit *)
(* type grid_t = unit *)
(* type input_t = unit *)

type name_t = string

(*type color_t = string*)

type color_t = int*int*int

type location_t = int * int

type particle_t = {name: name_t}   

type grid_dimensions = { mutable row: int; mutable col: int}

(* the type of an input *)
type input_t =
  ElemAdd of {elem: string; loc: int * int;} | Reset | Quit | Save | Load


module type Model = sig
    type grid_t
    val indices_of_particle : grid_t -> particle_t -> location_t list
    val particle_at_index : grid_t -> location_t -> particle_t option
    val empty_grid : int * int -> grid_t   
    val to_list : grid_t -> (location_t * particle_t) list 
    val get_grid_size : grid_t -> int * int
    val set_pixel : location_t -> particle_t option -> grid_t -> grid_t 
    val particle_to_string : particle_t option -> string
    val to_string : grid_t -> string
    val create_grid : (location_t * particle_t) array array -> grid_t
    val in_grid : grid_t -> location_t -> bool
    val deep_copy : grid_t -> grid_t -> unit
    val fold : ('a -> location_t -> particle_t option -> 'a) -> 'a -> grid_t -> 'a
    val iter : (location_t -> particle_t option-> 'a) -> grid_t -> unit
end

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

    let simple_row (rown:int) (coln:int) : ((int * int) * particle_t) array = 
      col_counter := (-1); Array.map (fun x -> 
      ((rown, next_val ()), {name = ""})) (Array.make coln 0)

    let empty_grid ((rows, cols):int*int) : grid_t= row_counter := (-1);
      Array.map (fun r -> simple_row (next_row ()) cols) (Array.make rows 0)

    let indices_of_particle (grid:grid_t) (particle: particle_t) : location_t list = 
      Array.fold_left (fun acc r -> 
        (Array.fold_left(fun acc_2 c -> 
          if ((snd c) = particle) then (fst c)::acc_2 else acc_2) acc r )) [] grid

    let particle_at_index (grid:grid_t) (location:location_t) : particle_t option = 
      try ( let result = snd (Array.get (Array.get grid (fst location)) (snd location))  in
          match result with
          | {name = ""} -> None
          | _ -> Some result )
      with e -> None


    let get_grid_size (grid:grid_t) : int*int = 
    (Array.length grid, Array.length (Array.get grid 0)) 

    let set_pixel (x,y) particle_opt grid = 
      let (r,c) = get_grid_size grid in
      let particle = match particle_opt with
      | None -> {name = ""}
      | Some p -> p
      in 
      if (x < r && x > (-1) && y < c && y > (-1)) then 
      Array.set (Array.get grid x)  (y) ((x,y),particle)
      else (); grid

    let create_grid (grid: (location_t*particle_t) array array) : grid_t = grid

    let particle_to_string = function
    | Some _ -> "*"
    | None -> "_"

    let to_string grid =
      let (max_x,max_y) = get_grid_size grid in
      Helpers.range 0 (max_x - 1) |> List.map
        (fun x -> Helpers.range 0 (max_y -1) |> List.map
          (fun y -> particle_to_string (particle_at_index grid (x,y)))
        )
      |> Helpers.transpose |> List.map (String.concat "") |>  String.concat "\n"

    let in_grid grid (x,y) =
      let (sx,sy) = get_grid_size grid in
      (x < sx) && (y < sy) && (y >= 0) && (x >= 0)

    let fold f acc (gr:grid_t)  = 
      let (cols, rows) = get_grid_size gr in
      let a = ref acc in 
      for x = 0 to cols - 1 do 
        for y = 0 to rows - 1 do  
          let (loc, part) = gr.(x).(y) in
          let p = match part with
            | {name = ""} -> None
            | _ -> Some part 
          in a := f !a loc p
        done
      done; !a 

    let to_list grid = 
       fold (fun acc loc part -> 
        let p = begin match part with
            | None -> {name = ""}  
            | Some particle -> particle 
        end in
        acc@[(loc,p)]) [] grid

    let iter f gr =
      let (cols, rows) = get_grid_size gr in
      for x = 0 to cols - 1 do 
        for y = 0 to rows - 1 do  
          let (loc, part) = gr.(x).(y) in 
          let p = match part with
            | {name = ""} -> None
            | _ -> Some part
          in f loc p; ()
        done
      done

    let deep_copy (from_g:grid_t) (to_g:grid_t) = 
      iter (fun loc part_opt -> set_pixel loc part_opt to_g) from_g
end