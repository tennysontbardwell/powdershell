open CamomileLibrary.UChar
open LTerm_key
open LTerm_geom
open LTerm_widget

type gui_t = LTerm_widget.t

class gui_ob exit_ =
  object(self)
    inherit LTerm_widget.frame as super
 
    val mutable toggle = false
    val mutable previous_location = None
    val mutable matrix = Array.make_matrix 100 100 0
    (* val mutable coords = {row = 0; col = 0} *)
    val mutable current_event = None

    method draw_to_screen m = 
    matrix <- m;
    self#queue_draw

    method draw ctx focused_widget =
      (* Calling super just for that frame wrapping, aka the |_| *)
      (* Make sure that row1 is smaller than row2
         and that col1 is smaller than col2, it goes:
                          row1
                      col1    col2
                          row2 *)
      LTerm_draw.clear ctx;
      super#draw ctx focused_widget;
      for x = 0 to 99 do
          for y = 0 to 99 do 
            LTerm_draw.draw_string ctx x y ~style:LTerm_style.({bold = None;
                                                    underline = None;
                                                    blink = Some false;
                                                    reverse = None;
                                                    foreground = Some lyellow;
                                                    background = None}) (if matrix.(x).(y) = 0 then "a" else "z")
          done
      done;



      if toggle then (LTerm_draw.draw_string ctx 5 5 ~style:LTerm_style.({bold = None;
                                                          underline = None;
                                                          blink = Some true;
                                                          reverse = None;
                                                          foreground = Some lyellow;
                                                          background = None}) "toggle"; toggle <- false
      )    else toggle <- true

    method get_input = let p = current_event in current_event <- None; p

    initializer
      self#on_event 
        (function
          | LTerm_event.Key
              {code = LTerm_key.Char ch}
            when ch = of_char 'q' ->
            exit_ ();
            true
          | e ->
            e |> LTerm_event.to_string |> print_endline;
            current_event <- Some (e);
            true
          | _ -> current_event <- None; false)
  end

(* let new_gui exit = new gui_ob exit *)

(* let get_inputs gui = gui#get_input *)

(* let draw_to_screen c gui = gui#draw_to_screen c *)
