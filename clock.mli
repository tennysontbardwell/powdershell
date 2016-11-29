type clock_t

(* [new_clk] is a blank clock with no target set (and so the next frame is *)
(* immediate) and a default fps of 60 *)
val new_clk : clock_t

val end_calc : clock_t -> clock_t

val get_speed : clock_t -> float

val set_start : clock_t -> clock_t