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
    matrix : ArrayModel.grid_t;
    event_buffer : input_t list;
    selected_elem : string;
    draw_radius : int;
    element_list : string list;
    controls_list : string * (int -> unit) list;
    rules_lookop : Rules.rules_t;
    is_paused : bool;
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

  val mutable matrix = ArrayModel.empty_grid (1, 1)
  val mutable event_buffer = []
  val mutable selected_elem = "sand"
(*   val mutable ui = {
    matrix = ArrayModel.empty_grid (1, 1);
    event_buffer = [];
    selected_elem = "sand";
    draw_radius = 3;
    element_list = [];
    controls_list = [];
    rules_lookop = gen_rules [];
    is_paused = false;
  } *)
  val mutable draw_radius = 3
  val mutable element_list = []
  val mutable controls_list = []
  val mutable space = 2
  val mutable debug = ""
  val mutable rules_lookop = gen_rules []
  val mutable paused = false
  val mutable pp_button = ("", fun _ -> ())

  method create_matrix c r = matrix <- ArrayModel.empty_grid (c, r);

  method load_rules r = rules_lookop <- r; 
    element_list <- "erase"::(Hashtbl.fold (fun x _ a -> x::a) rules_lookop [])

  method draw_to_screen m = 
    matrix <- m;
    self#queue_draw

  method set_debug s = debug <- s

  method is_paused = paused

  method draw ctx focused_widget =
    LTerm_draw.clear ctx;

    let (cols, rows) = ArrayModel.get_grid_size matrix in
    List.fold_left (fun a x -> 
      let color = if x = "erase" then Some lwhite else
      let (r, g, b) = (lookup_rule rules_lookop x).color in Some (rgb r g b) in
        LTerm_draw.draw_string ctx a (cols + 2) ~style:LTerm_style.({
          bold = (if x = selected_elem then Some true else None);
          underline = (if x = selected_elem then Some true else None);
          blink = None; reverse = None; foreground = color; background = None
        }) x; 
      a + space) 10 element_list;

    let control_string = 
      List.fold_left (fun a (x, _) -> a ^ x ^ "   ") "" controls_list in        
    LTerm_draw.draw_string ctx (rows + 2) 3 control_string; 
    LTerm_draw.draw_string ctx (rows + 2) 48 (string_of_int draw_radius);
    LTerm_draw.draw_string ctx (rows + 2) 80 (debug);
    let frame_rect = {row1 = 0; col1 = 0; row2 = rows + 2; col2 = cols + 2} in
    LTerm_draw.draw_frame ctx frame_rect LTerm_draw.Light;

    let constrain a l h = if a < l then l else if a > h then h else a in
    for x = 0 to cols do 
      for y = 0 to rows do
        match ArrayModel.particle_at_index matrix (x, y) with
        | None -> ()
        | Some {name = n} ->
          let details = lookup_rule rules_lookop n in
          let (rawr, rawg, rawb) = details.color in
          let shim = Random.int details.shimmer - (details.shimmer/2) in 
          let (r, g, b) = (constrain (shim + rawr) 0 255,
                           constrain (shim + rawg) 0 255, 
                           constrain (shim + rawb) 0 255) in
          LTerm_draw.draw_string ctx (y + 1) (x + 1) ~style:LTerm_style.({
          bold = None; underline = None; blink = Some false; 
          reverse = None; foreground = Some (rgb r g b); background = None}) 
          (details.display)
      done
    done;


  method get_input = let p = event_buffer in event_buffer <- []; p

  (* This needs to be here for mouse inputs to work *)
  method can_focus = true

  method get_size = ArrayModel.get_grid_size matrix

  method setup = 
  self#on_event self#handle_input;
  (* set up controls *)
  let actions = [
    ("quit", fun _ -> self#exit_term);
    ("reset", fun _ -> event_buffer <- Reset::event_buffer);
    ("save", fun _ -> event_buffer <- Save::event_buffer); 
    ("load", fun _ -> event_buffer <- Load::event_buffer); 
    ("line", fun _ -> ());
    ("radius: - +", fun x -> 
      if (x = 4 && draw_radius < 9) then
        draw_radius <- draw_radius + 1
      else if (x = 6 && draw_radius > 1) then
        draw_radius <- draw_radius - 1 else ())
    ] in 
    let p_to_string p = if p then "play" else "pause" in
    pp_button <- (p_to_string paused, fun _ -> paused <- not paused;
        controls_list <- (actions @ [(p_to_string paused, snd pp_button)]));
    controls_list <- (actions @ [pp_button])

  method private handle_buttons r c =
      let (cols, rows) = ArrayModel.get_grid_size matrix in
      if r >= rows + 2 then 
        let counter = ref (3) in
        let rec control_handle = function
        | (h, d)::t -> (counter := (!counter + String.length h + 3); 
            if (c < !counter) then
                d (!counter - c)
            else control_handle t)
        | _ -> () in
        control_handle controls_list
      else 
        let counter = ref (10 - space) in
        let assoc_list = (List.map (fun n -> 
          (counter := !counter + space; (!counter, n))) element_list) in
        if List.mem_assoc r assoc_list then 
          (selected_elem <- List.assoc r assoc_list);

  method private exit_term = 
      Lazy.force LTerm.stdout 
      >>= (fun term -> LTerm.disable_mouse term); 
      exit_ (); ()

  method private add_elem x y = 
      let dista (ax,ay) (bx,by) = sqrt((ax -. bx)**2. +. (ay -. by)**2.) in

      let (colsize, rowsize) = get_grid_size matrix in
      let r = draw_radius in
      for i = x - r to x + r do
          for j = y - r to y + r do
              if i >= 0 && j >= 0 && i < colsize && j < rowsize
                  && (dista (float i, float j) (float x, float y) +. 0.1) < (float r) then
              event_buffer <- (ElemAdd {elem = selected_elem; loc = (i,j)})::event_buffer
              else ()
          done
      done

  method private handle_input e = match e with
    | LTerm_event.Key {code = LTerm_key.Char ch} -> begin
      match char_of ch with
      | 'q' | 'c' -> self#exit_term; true
      | 'r' -> event_buffer <- Reset::event_buffer; true
      | 's' -> event_buffer <- Save::event_buffer; true
      | 'l' -> event_buffer <- Load::event_buffer; true
      | '+' | '=' -> if draw_radius < 9 then draw_radius <- draw_radius + 1; true
      | '-' -> if draw_radius > 1 then draw_radius <- draw_radius - 1; true
      | ' ' -> let p_to_string p = if p then "play" else "pause" in
          List.assoc (p_to_string paused) controls_list 1; true
      | c -> let num = (int_of_char c) - 48 in 
          if num >= 0 && num <= 9 && num < List.length element_list then 
            selected_elem <- List.nth element_list num; true
    end
    | LTerm_event.Mouse {row = r; col = c} -> 
      let (colsize, rowsize) = get_grid_size matrix in
      if r < rowsize + 2 && c < colsize + 2 then
      self#add_elem (c - 1) (r - 1)
      else self#handle_buttons r c;
      true
    | _ -> false

end
