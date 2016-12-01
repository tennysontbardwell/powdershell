open CamomileLibrary.UChar
open LTerm_key
open LTerm_geom
open LTerm_widget
open LTerm_style
open Lwt
open Model
open ArrayModel
open Rules

type gui_t = LTerm_widget.t

type ui_t = 
  {
    mutable matrix : ArrayModel.grid_t;
    mutable event_buffer : input_t list;
    mutable selected_elem : string;
    mutable draw_radius : int;
    mutable element_list : string list;
    mutable controls_list : (string * (int -> unit)) list;
    mutable rules : Rules.rules_t;
    mutable is_paused : bool;
  }

let setup_gui rules term gui =
    gui#setup;
    gui#load_rules rules;
    LTerm.enable_mouse term;
    let raw_size = LTerm.size term in
    let size = {cols= if raw_size.cols > 218 then 218 else raw_size.cols ;
                rows= if raw_size.rows > 218 then 218 else raw_size.rows } in
    gui#create_matrix (size.cols - 7) (size.rows - 3)

let get_window_size gui = gui#get_size

let get_inputs gui = gui#get_input

let draw_to_screen c gui = gui#draw_to_screen c

let is_paused gui = gui#is_paused

class gui_ob exit_ = object(self)
  inherit LTerm_widget.frame as super

  val ui = {
    matrix = ArrayModel.empty_grid (1, 1);
    event_buffer = [];
    selected_elem = "sand";
    draw_radius = 3;
    element_list = [];
    controls_list = [];
    rules = gen_rules [];
    is_paused = false;
  }

  val elems_space = 2
  val mutable debug = ""

  method create_matrix c r = ui.matrix <- ArrayModel.empty_grid (c, r);

  method load_rules r = ui.rules <- r; 
    ui.element_list <- "erase"::(Hashtbl.fold (fun x r a -> if r.show then x::a else a) ui.rules [])

  method draw_to_screen m = 
    ui.matrix <- m;
    self#queue_draw

  method set_debug s = debug <- s

  method is_paused = ui.is_paused

  method draw ctx focused_widget =
    LTerm_draw.clear ctx;
    let (cols, rows) = ArrayModel.get_grid_size ui.matrix in
    List.fold_left (fun a x -> 
      let color = if x = "erase" then Some lwhite else
        let (r, g, b) = (lookup_rule ui.rules x).color in
      Some (rgb r g b) in
        LTerm_draw.draw_string ctx a (cols + 2) ~style:LTerm_style.({
          bold = (if x = ui.selected_elem then Some true else None);
          underline = (if x = ui.selected_elem then Some true else None);
          blink = None; reverse = None; foreground = color; background = None
        }) x; 
      a + elems_space) 10 ui.element_list;

    let control_string = 
      List.fold_left (fun a (x, _) -> a ^ x ^ "   ") "" ui.controls_list in        
    LTerm_draw.draw_string ctx (rows + 2) 3 control_string; 
    LTerm_draw.draw_string ctx (rows + 2) 48 (string_of_int ui.draw_radius);
    LTerm_draw.draw_string ctx (rows + 2) 80 (debug);
    let frame_rect = {row1 = 0; col1 = 0; row2 = rows + 2; col2 = cols + 2} in
    LTerm_draw.draw_frame ctx frame_rect LTerm_draw.Light;

    let constrain a l h = if a < l then l else if a > h then h else a in
    for x = 0 to cols do 
      for y = 0 to rows do
        match ArrayModel.particle_at_index ui.matrix (x, y) with
        | None -> ()
        | Some {name = n} ->
          let details = lookup_rule ui.rules n in
          let (rawr, rawg, rawb) = details.color in
          let (r, g, b) = let shim = details.shimmer in 
          if shim = 0 then (rawr, rawg, rawb) else
          let shimmer = Random.int shim - (shim/2) in 
              (constrain (shimmer + rawr) 0 255,
               constrain (shimmer + rawg) 0 255, 
               constrain (shimmer + rawb) 0 255) in
          LTerm_draw.draw_string ctx (y + 1) (x + 1) ~style:LTerm_style.({
          bold = None; underline = None; blink = Some false; 
          reverse = None; foreground = Some (rgb r g b); background = None})
          details.display
      done
    done;

  method get_input = let p = ui.event_buffer in ui.event_buffer <- []; p

  (* This needs to be here for mouse inputs to work *)
  method can_focus = true

  method get_size = ArrayModel.get_grid_size ui.matrix

  method setup = 
  self#on_event self#handle_input;
  (* set up controls *)
  let actions = [
    ("quit", fun _ -> self#exit_term);
    ("reset", fun _ -> ui.event_buffer <- Reset::(ui.event_buffer));
    ("save", fun _ -> ui.event_buffer <- Save::(ui.event_buffer)); 
    ("load", fun _ -> ui.event_buffer <- Load::(ui.event_buffer)); 
    ("line", fun _ -> ());
    ("radius: - +", fun x -> 
      if (x = 4 && ui.draw_radius < 9) then
        ui.draw_radius <- ui.draw_radius + 1
      else if (x = 6 && ui.draw_radius > 1) then
        ui.draw_radius <- ui.draw_radius - 1 else ())
    ] in 
    let pp_button = ref ("", fun _ -> ()) in
    let p_to_string p = if p then "play" else "pause" in
    pp_button := (p_to_string ui.is_paused, fun _ ->
        ui.is_paused <- not ui.is_paused;
        ui.controls_list <- (actions @
        [(p_to_string ui.is_paused, snd !pp_button)]));
    ui.controls_list <- (actions @ [!pp_button])

  method private handle_buttons r c =
      let (cols, rows) = ArrayModel.get_grid_size ui.matrix in
      if r >= rows + 2 then 
        let steps = ref (3) in
        let rec control_handle = function
        | (h, d)::t -> (steps := (!steps + String.length h + 3); 
            if (c < !steps) then
                d (!steps - c)
            else control_handle t)
        | _ -> () in
        control_handle ui.controls_list
      else 
        let steps = ref (10 - elems_space) in
        let assoc_list = (List.map (fun n -> 
          (steps := !steps + elems_space; (!steps, n))) ui.element_list) in
        if List.mem_assoc r assoc_list then 
          (ui.selected_elem <- List.assoc r assoc_list);

  method private exit_term = 
      Lazy.force LTerm.stdout 
      >>= (fun term -> LTerm.disable_mouse term); 
      exit_ (); ()

  method private add_elem x y = 
      let dist (ax,ay) (bx,by) = sqrt(((float ax) -. (float bx))**2. +.
          ((float ay) -. (float by))**2.) in
      let (colsize, rowsize) = get_grid_size ui.matrix in
      let r = ui.draw_radius in
      for i = x - r to x + r do
          for j = y - r to y + r do
              if i >= 0 && j >= 0 && i < colsize && j < rowsize
                  && (dist (i, j) (x, y) +. 0.1) < (float r) then
              ui.event_buffer <- (ElemAdd {elem = ui.selected_elem;
                  loc = (i,j)})::(ui.event_buffer)
              else ()
          done
      done

  method private handle_input e = match e with
    | LTerm_event.Key {code = LTerm_key.Char ch} -> begin
      match char_of ch with
      | 'q' | 'c' -> self#exit_term; true
      | 'r' -> ui.event_buffer <- Reset::(ui.event_buffer); true
      | 's' -> ui.event_buffer <- Save::(ui.event_buffer); true
      | 'l' -> ui.event_buffer <- Load::(ui.event_buffer); true
      | '+' | '=' -> if ui.draw_radius < 9 then
                     ui.draw_radius <- ui.draw_radius + 1; true
      | '-' -> if ui.draw_radius > 1 then
               ui.draw_radius <- ui.draw_radius - 1; true
      | ' ' -> let p_to_string p = if p then "play" else "pause" in
          List.assoc (p_to_string ui.is_paused) ui.controls_list 1; true
      | c -> let num = (int_of_char c) - 48 in 
          if num >= 0 && num <= 9 && num < List.length ui.element_list then 
            ui.selected_elem <- List.nth ui.element_list num; true
    end
    | LTerm_event.Mouse {row = r; col = c; button = b} -> 
      let (colsize, rowsize) = get_grid_size ui.matrix in
      if r < rowsize + 2 && c < colsize + 2 then
      self#add_elem (c - 1) (r - 1)
      else if b = Button1 then self#handle_buttons r c; true
    | _ -> false

end
