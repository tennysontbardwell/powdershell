open CamomileLibrary.UChar
open LTerm_key
open LTerm_geom
open LTerm_widget
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
    val mutable element_list = ["sand"; "water"; "ice"; "vine"; "lava"]
    val mutable actions_list = [("reset", Reset); ("save", Save); ("load", Reset); ("quit", Quit)]
    val mutable space = 2

    method create_matrix r c =
    matrix <- ArrayModel.empty_grid (r, c);
    (* self#set_allocation {row1 = 0; col1 = 0; row2 = r; col2 = c}; *)

    method draw_to_screen m = 
    matrix <- m;
    self#queue_draw

    method set_allocation x = super#set_allocation x

    method draw ctx focused_widget =
      (* Calling super just for that frame wrapping, aka the |_| *)
      (* Make sure that row1 is smaller than row2
         and that col1 is smaller than col2, it goes:
                          row1
                      col1    col2
                          row2 *)
      LTerm_draw.clear ctx;
      let (rows, cols) = ArrayModel.get_grid_size matrix in
      (* super#draw ctx focused_widget; *)
      (* print_int rows; print_string ","; print_int cols; print_endline ""; *)
    LTerm_draw.draw_frame ctx {row1 = 0; col1 = 0; row2 = rows; col2 = cols} LTerm_draw.Light;

      for x = 0 to rows do 
        for y = 0 to cols do
            match ArrayModel.particle_at_index matrix (x, y) with
            | None -> ()
            | Some {name = n; color = c} ->
                LTerm_draw.draw_string ctx x y ~style:LTerm_style.({
                bold = None; underline = None; blink = Some false; 
                reverse = None; foreground = Some lyellow; background = None}) n
        done
      done;
      List.fold_left (fun a x -> 
        (* let color = if a = curr_element then Some lyellow else Some lwhite in *)
        LTerm_draw.draw_string ctx a cols ~style:LTerm_style.({
            bold = None; underline = None; blink = Some true; 
            reverse = None; foreground = Some lwhite; background = 
            (if x = curr_element then Some lyellow else None)}) x; 
        a + space
      ) 10 element_list;

      let control_string = List.fold_left (fun a (x, _) -> a ^ x ^ "   ") ""
       actions_list in        
       LTerm_draw.draw_string ctx rows 3 ~style:LTerm_style.({
            bold = None; underline = None; blink = Some true; 
            reverse = None; foreground = Some lwhite; background = None}) control_string; 

      if toggle then 
        (LTerm_draw.draw_string ctx 0 cols ~style:LTerm_style.({
        bold = None; underline = None; blink = Some true; reverse = None;
        foreground = Some lgreen; background = None}) "clock"; toggle <- false)
      else toggle <- true

    method get_input = current_event

    method can_focus = true

    method get_size = (size.rows, size.cols)

    method setup = 
        Lazy.force LTerm.stdout 
        >>= (fun term -> 
            (size <- LTerm.size term;
             (* self#create_matrix size.rows size.cols; *)
             (* self#create_matrix 1000 1000 ;*)
             (* print_int (size.rows); *)
             LTerm.enable_mouse term)
            >>= (fun () -> begin  LTerm.enter_raw_mode term end));
        
        (* print_int (Array.length matrix); *)
        (* print_int (size.rows); *)
        (* self#set_allocation {row1 = 0; col1 = 0; row2 = size.rows - 2; col2 = size.cols - 2}; *)
        ()



    method handle_buttons r c =
        let (rows, cols) = ArrayModel.get_grid_size matrix in
        if r >= rows then
        let counter = ref (3) in
        let rec control_handle = function
        | (h, d)::t -> (counter := (!counter + String.length h + 3); 
            if (c < !counter) then
                if h = "quit" then 
                self#exit_term else 
                current_event <- d::current_event
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
            (* e |> LTerm_event.to_string |> print_endline; *)
            let (rowsize, colsize) = get_grid_size matrix in
            if r < rowsize && c < colsize then
            current_event <- (ElemAdd {elem = curr_element; loc = (r,c)})::current_event
            else self#handle_buttons r c;
            true
          | _ -> false)

  end

(* let new_gui exit = new gui_ob exit *)

let get_window_size gui = gui#get_size

let get_inputs gui = gui#get_input

let draw_to_screen c gui = gui#draw_to_screen c
