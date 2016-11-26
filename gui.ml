open CamomileLibrary.UChar
open LTerm_key
open LTerm_geom
open LTerm_widget
open Lwt
open Model

type gui_t = LTerm_widget.t

class gui_ob exit_ =
  object(self)
    inherit LTerm_widget.frame as super
 
    val mutable toggle = false
    val mutable matrix = Array.make_matrix 1000 1000 None
    (* val mutable coords = {row = 0; col = 0} *)
    val mutable current_event = None
    val mutable size = {rows = 1000; cols = 1000}

    method create_matrix r c =
    matrix <- Array.make_matrix r c 0;

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
      super#draw ctx focused_widget;
      Array.iteri (fun x row -> Array.iteri (
      fun y cell -> match cell with
        | None -> ()
        | Some {name = n; color = c} ->
            LTerm_draw.draw_string ctx x y ~style:LTerm_style.({
            bold = None; underline = None; blink = Some false; 
            reverse = None; foreground = Some lyellow; background = None}) n
      ) row) matrix;

      if toggle then 
        (LTerm_draw.draw_string ctx 0 0 ~style:LTerm_style.({
        bold = None; underline = None; blink = Some true; reverse = None;
        foreground = Some lyellow; background = None}) "clock"; toggle <- false)
      else toggle <- true

    method get_input = match current_event with 
    | Some (LTerm_event.Mouse {row = r; col = c}) -> 
        current_event <- None; [(ElemAdd { elem = "sand"; loc = (r,c)})]
    | _ -> []

    method can_focus = true

    method get_size = (size.rows, size.cols)

    method setup = 
        Lazy.force LTerm.stdout 
        >>= (fun term -> 
            (size <- LTerm.size term;
             self#create_matrix size.rows size.cols;
             (* print_int (size.rows); *)
             LTerm.enable_mouse term)
            >>= (fun () -> begin  LTerm.enter_raw_mode term end));
        
        (* print_int (Array.length matrix); *)
        (* print_int (size.rows); *)
        (* self#set_allocation {row1 = 0; col1 = 0; row2 = size.rows - 2; col2 = size.cols - 2}; *)
        ()

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
          | e ->
            (* e |> LTerm_event.to_string |> print_endline; *)
            current_event <- Some (e);
            true
          | _ -> current_event <- None; false)

  end

(* let new_gui exit = new gui_ob exit *)

let get_window_size gui = gui#get_size

let get_inputs gui = gui#get_input

let draw_to_screen c gui = gui#draw_to_screen c
