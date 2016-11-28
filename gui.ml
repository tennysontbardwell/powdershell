open CamomileLibrary.UChar
open LTerm_key
open LTerm_geom
open LTerm_widget
open LTerm_style
open Lwt
open Model
open ArrayModel

type gui_t = LTerm_widget.t

class gui_ob exit_ =
  object(self)
    inherit LTerm_widget.frame as super
 
    val mutable toggle = false
    val mutable matrix = ArrayModel.empty_grid (1, 1)
    val mutable current_event = []
    val mutable size = {rows = 1000; cols = 1000}
    val mutable curr_element = "sand"
    val mutable radius = 1
    val mutable element_list = ["sand"; "water"; "ice"]
    val mutable actions_list = []
    val mutable space = 2
    val mutable debug = ""
    val offset = 1

    method create_matrix c r =
    matrix <- ArrayModel.empty_grid (c, r);
    (* self#set_allocation {row1 = 0; col1 = 0; row2 = r; col2 = c}; *)

    method draw_to_screen m = 
    matrix <- m;
    self#queue_draw

    method set_allocation x = super#set_allocation x

    method draw ctx focused_widget =
      LTerm_draw.clear ctx;
      let (cols, rows) = ArrayModel.get_grid_size matrix in
      (* print_int rows; print_string ","; print_int cols; print_endline ""; *)
      LTerm_draw.draw_frame ctx {row1 = 0; col1 = 0; row2 = rows + 2; col2 = cols + 2} LTerm_draw.Light;

      for x = 0 to cols do 
        for y = 0 to rows do
            match ArrayModel.particle_at_index matrix (x, y) with
            | None -> ()
            | Some {name = n; color = c} ->
                LTerm_draw.draw_string ctx (y + offset) (x + offset) ~style:LTerm_style.({
                bold = None; underline = None; blink = Some false; 
                reverse = None; foreground = Some (rgb ((Random.int 20) + 235) ((Random.int 40) + 155) 5); background = None}) 
                (String.sub n 0 1)
        done
      done;
      List.fold_left (fun a x -> 
        (* let color = if a = curr_element then Some lyellow else Some lwhite in *)
        LTerm_draw.draw_string ctx a (cols + 2) ~style:LTerm_style.({
            bold = None; underline = None; blink = Some false; 
            reverse = None; foreground = Some lwhite; background = 
            (if x = curr_element then Some lyellow else None)}) x; 
        a + space
      ) 10 element_list;

      let control_string = List.fold_left (fun a (x, _) -> a ^ x ^ "   ") ""
       actions_list in        
       LTerm_draw.draw_string ctx (rows + (offset * 2)) 3 ~style:LTerm_style.({
            bold = None; underline = None; blink = Some false; 
            reverse = None; foreground = Some lwhite; background = None}) control_string; 
        
       LTerm_draw.draw_string ctx (rows + (offset * 2)) 48 ~style:LTerm_style.({
            bold = None; underline = None; blink = Some false; 
            reverse = None; foreground = Some lwhite; background = None}) (string_of_int radius); 

       LTerm_draw.draw_string ctx (rows + (offset * 2)) 78 ~style:LTerm_style.({
            bold = None; underline = None; blink = Some false; 
            reverse = None; foreground = Some lwhite; background = None}) (debug); 
       

      if toggle then 
        (LTerm_draw.draw_string ctx 0 cols ~style:LTerm_style.({
        bold = None; underline = None; blink = Some false; reverse = None;
        foreground = Some lgreen; background = None}) "clock"; toggle <- false)
      else toggle <- true

    method get_input = let p = current_event in current_event <- []; p

    method can_focus = true

    method get_size = (size.rows, size.cols)

    method setup = 
    actions_list <- [("quit", fun _ -> self#exit_term);
                        ("reset", fun _ -> current_event <- Reset::current_event);
                        ("save", fun _ -> current_event <- Save::current_event); 
                        ("load", fun _ -> ()); 
                        ("line", fun _ -> ());
                        ("radius: - +", fun x -> 
                            if (x = 4 && radius < 9) then radius <- radius + 1 else if (x = 6 && radius > 1) then radius <- radius - 1 else ())];
        Lazy.force LTerm.stdout 
        >>= (fun term -> 
            (size <- LTerm.size term;
             (* self#create_matrix size.rows size.cols; *)
             (* self#create_matrix 1000 1000 ;*)
             (* print_int (size.rows); *)
             LTerm.enable_mouse term)
            >>= (fun () -> begin  LTerm.enter_raw_mode term end));
        
        (* print_int (Array.length matrix); *)
        (* print_int (size.cols); *)
        self#set_allocation {row1 = 0; col1 = 0; row2 = size.rows; col2 = size.cols};
        ()

    method handle_buttons r c =
        let (cols, rows) = ArrayModel.get_grid_size matrix in
        if r >= rows + 2 then
        let counter = ref (3) in
        let rec control_handle = function
        | (h, d)::t -> (counter := (!counter + String.length h + 3); 
            if (c < !counter) then
                d (!counter - c)
            else control_handle t)
        | _ -> () in
        control_handle actions_list
        else
        let counter = ref (10 - space) in
        let assoc_list = (List.map (fun n -> (counter := !counter + space; (!counter, n))) element_list) in
        if List.mem_assoc r assoc_list then (curr_element <- List.assoc r assoc_list) else ()
        (* (print_int r; print_string ","; print_int c; print_endline "") *)

    method exit_term = 
        Lazy.force LTerm.stdout 
        >>= (fun term -> LTerm.disable_mouse term); 
        exit_ (); ()

    method private add_elem x y = 
        let dista (ax,ay) (bx,by) = sqrt((ax -. bx)**2. +. (ay -. by)**2.) in
        let (colsize, rowsize) = get_grid_size matrix in
        let r = radius in
        for i = x - r to x + r do
            for j = y - r to y + r do
                if(i >= 0 && j >= 0 && i < colsize && j < rowsize
                    && ((dista (float i, float j) (float x, float y) +. 0.1 )< (float r) )) then
                current_event <- (ElemAdd {elem = curr_element; loc = (i,j)})::current_event
                else ()
            done
        done

    initializer
      self#setup;
      self#on_event 
        (function
          | LTerm_event.Key
              {code = LTerm_key.Char ch}
            when ch = of_char 'q' ->
            self#exit_term;
            true
          | LTerm_event.Mouse {row = r; col = c} -> 
            (* debug <- ("c:" ^ (string_of_int c) ^ " r:" ^ (string_of_int r)); *)
            let (colsize, rowsize) = get_grid_size matrix in
            (* debug <- ("c:" ^ (string_of_int c) ^ " r:" ^ (string_of_int r) ^ " cols: " ^ (string_of_int colsize) ^ " rows: " ^ (string_of_int rowsize)); *)
            if r < rowsize + 2 && c < colsize + 2 then
            self#add_elem (c - 1) (r - 1)
            else self#handle_buttons r c;
            true
          | _ -> false)

  end

(* let new_gui exit = new gui_ob exit *)

let get_window_size gui = gui#get_size

let get_inputs gui = gui#get_input

let draw_to_screen c gui = gui#draw_to_screen c
