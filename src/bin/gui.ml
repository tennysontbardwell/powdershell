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
    mutable selected_elem : string * string;
    mutable draw_radius : int;
    mutable element_list : string list;
    mutable controls_list : (string * (int -> unit)) list;
    mutable rules : Rules.rules_t;
    mutable is_paused : bool;
    mutable elems_lst_format : int * int;
  }

let setup_gui rules term gui =
    gui#load_rules rules;
    ignore (LTerm.enable_mouse term);
    let raw_size = LTerm.size term in
    let size = {cols= if raw_size.cols > 218 then 218 else raw_size.cols ;
                rows= if raw_size.rows > 218 then 218 else raw_size.rows } in
    gui#create_matrix (size.cols - 7) (size.rows - 3);
    gui#setup

let get_window_size gui = gui#get_size

let get_inputs gui = gui#get_input

let draw_to_screen c gui = gui#draw_to_screen c

let is_paused gui = gui#is_paused

let help_text = "
Welcome to Powder Shell!\n
Made by Quinn, Sitar, and Tennyson\n \n
Right and left click to select elements from the element list on the right side.\n
Select elements with right or left click to bind them to the respective button. \n
Many useful tools can be found in the bottom toolbar and are also bound to keys!\n
Keys are bound as follows:                                                      \n
    'h' : open this help screen                                                 \n
    'q' : quit                                                                  \n
    'r' : reset game                                                            \n
    's' : save game to a file                                                   \n
    'l' : load game from a file                                                 \n
    '+' / '-' : change drawing radius size                                      \n
    space : toggle play and pause                                               \n
Elements will react with each other in cool ways!                               \n
Have fun and get creative!                                                      \n
 "

(* This exists to allow LTerm_edit.edit widgets to appear within modals *)
class text_inp = object(self)
  inherit LTerm_edit.edit () as super

  method size_request = {rows = 1; cols = 10}
end

class gui_ob push_layer pop_layer exit_ = object(self)
  inherit LTerm_widget.frame as super

  val ui = {
    matrix = ArrayModel.empty_grid (1, 1);
    event_buffer = [];
    selected_elem = ("sand", "erase");
    draw_radius = 3;
    element_list = [];
    controls_list = [];
    rules = gen_rules [];
    is_paused = false;
    (* offset, space *)
    elems_lst_format = (10, 2);
  }

  method create_matrix c r = ui.matrix <- ArrayModel.empty_grid (c, r);

  method load_rules r = ui.rules <- r;
    ui.element_list <- "erase"::(List.fold_right (fun x a -> 
      if (lookup_rule ui.rules x).show then x::a else a)
    (Rules.get_name_lst ui.rules) [])

  method draw_to_screen m = 
    ui.matrix <- m;
    self#queue_draw

  method is_paused = ui.is_paused

  method draw ctx focused_widget =
    LTerm_draw.clear ctx;
    let (cols, rows) = ArrayModel.get_grid_size ui.matrix in
    let (f_off, f_space) = ui.elems_lst_format in
    List.fold_left (fun a x -> 
      let (lc, rc) = ui.selected_elem in
      let color = if x = "erase" then Some lwhite else
        let (r, g, b) = (lookup_rule ui.rules x).color in
      Some (rgb r g b) in
        LTerm_draw.draw_string ctx a (cols+2) ~style:LTerm_style.({
          bold = None; underline = if x = lc || x = rc then Some true else None;
          blink = None; reverse = None; foreground = color; background = None
        }) (if x = lc then String.uppercase x else x); 
      a + f_space) f_off ui.element_list |> ignore;

    let control_string = 
      List.fold_left (fun a (x, _) -> a ^ x ^ "   ") "" ui.controls_list in        
    LTerm_draw.draw_string ctx (rows + 2) 3 control_string; 
    LTerm_draw.draw_string ctx (rows + 2) 48 (string_of_int ui.draw_radius);
    let frame_rect = {row1 = 0; col1 = 0; row2 = rows + 2; col2 = cols + 2} in
    LTerm_draw.draw_frame ctx frame_rect LTerm_draw.Light;

    let constrain a l h = if a < l then l else if a > h then h else a in
    ArrayModel.iter (fun (x,y) -> function
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
          details.display) ui.matrix

  method get_input = let p = ui.event_buffer in ui.event_buffer <- []; p

  (* This needs to be here for mouse inputs to work *)
  method can_focus = true

  method get_size = ArrayModel.get_grid_size ui.matrix

  method setup = 
    self#on_event self#handle_input;
    (* set up controls *)    
    let (f_off, f_space) = ui.elems_lst_format in
    if List.length ui.element_list * f_space + f_off > (ArrayModel.get_grid_size ui.matrix |> snd) 
    then ui.elems_lst_format <- (2, 1);

    let help_modal = new LTerm_widget.modal_frame in
    let help_box = new vbox in 
    let help_message = new label help_text in
    let exit_button = new button "exit" in
    exit_button#on_click (pop_layer);
    help_box#add help_message;
    help_box#add exit_button;
    help_modal#set help_box;

    (* function to create the save and load pop ups, 
     * utilizes higher order callback function *)
    let create_textbox str callback = 
      let editor = new text_inp in
      let frame = new LTerm_widget.frame in
      let layer = new LTerm_widget.modal_frame in
      let box = new vbox in
      let message = new label str in
      editor#bind
         [{control = false; meta = false; shift = false; code = Escape}]
         [LTerm_edit.Custom (fun () -> pop_layer ())];
      editor#bind
         [{control = false; meta = false; shift = false; code = Enter}]
         [LTerm_edit.Custom (fun () -> pop_layer (); callback editor#text)];
      frame#set editor;
      box#add message;
      box#add frame;
      layer#set box;
      layer in 
    let load_modal = create_textbox 
      "What save file would you like to load?\nPress enter to load or esc to cancel."
      (fun str -> ui.event_buffer <- (Load str)::(ui.event_buffer)) in
    let save_modal = create_textbox 
      "What would you like to name this save?\nPress enter to save or esc to cancel."
      (fun str -> ui.event_buffer <- (Save str)::(ui.event_buffer)) in

    let actions = [
      ("quit", fun _ -> self#exit_term);
      ("help", fun _ -> push_layer help_modal ());
      ("reset", fun _ -> ui.event_buffer <- Reset::(ui.event_buffer));
      ("save", fun _ -> push_layer save_modal ()); 
      ("load", fun _ -> push_layer load_modal ()); 
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

  (* handles mouse input when not clicked inside the grid. r, c is the inputted 
   * coordinates and b is the pressed button *)
  method private handle_buttons r c b =
      let (cols, rows) = ArrayModel.get_grid_size ui.matrix in
      let (f_off, f_space) = ui.elems_lst_format in
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
        let steps = ref (f_off - f_space) in
        let assoc_list = (List.map (fun n -> 
          (steps := !steps + f_space; (!steps, n))) ui.element_list) in
        if List.mem_assoc r assoc_list then 
        if b = LTerm_mouse.Button1 then
          (ui.selected_elem <- (List.assoc r assoc_list, snd ui.selected_elem))
        else
          (ui.selected_elem <- (fst ui.selected_elem, List.assoc r assoc_list))

  (* call this function to exit the gui *)
  method private exit_term = 
      Lazy.force LTerm.stdout 
      >>= (fun term -> LTerm.disable_mouse term) |> ignore; 
      exit_ (); ()

  (* handles adding elements with a certain radius size, adds ElemAdds to 
   * input buffer *)
  method private add_elem x y right = 
      let dist (ax,ay) (bx,by) = sqrt(((float ax) -. (float bx))**2. +.
          ((float ay) -. (float by))**2.) in
      let (colsize, rowsize) = get_grid_size ui.matrix in
      let r = ui.draw_radius in
      for i = x - r to x + r do
          for j = y - r to y + r do
              if i >= 0 && j >= 0 && i < colsize && j < rowsize
                  && (dist (i, j) (x, y) +. 0.1) < (float r) then
              let (lc, rc) = ui.selected_elem in
              ui.event_buffer <- (ElemAdd {elem = if right then rc
                else lc; loc = (i,j)})::(ui.event_buffer)
              else ()
          done
      done

  (* handles all inputs of type LTerm_event.t *)
  method private handle_input e = match e with
    | LTerm_event.Key {code = LTerm_key.Char ch} -> begin
      match char_of ch with
      | 'q' | 'c' -> self#exit_term; true
      | 'r' -> ui.event_buffer <- Reset::(ui.event_buffer); true
      | 's' -> List.assoc "save" ui.controls_list 1; true
      | 'l' -> List.assoc "load" ui.controls_list 1; true
      | 'h' -> List.assoc "help" ui.controls_list 1; true
      | '+' | '=' -> if ui.draw_radius < 9 then
                     ui.draw_radius <- ui.draw_radius + 1; true
      | '-' -> if ui.draw_radius > 1 then
               ui.draw_radius <- ui.draw_radius - 1; true
      | ' ' -> let p_to_string p = if p then "play" else "pause" in
          List.assoc (p_to_string ui.is_paused) ui.controls_list 1; true
      | c -> let num = (int_of_char c) - 48 in 
          if num >= 1 && num <= 9 then ui.draw_radius <- num; true
    end
    | LTerm_event.Mouse {row = r; col = c; button = b} -> 
      let (colsize, rowsize) = get_grid_size ui.matrix in
      if r < rowsize + 2 && c < colsize + 2 then
      self#add_elem (c - 1) (r - 1) (b = Button3)
      else if b = Button1 || b = Button3 then self#handle_buttons r c b; true
    | _ -> false

end
