type clock

(* [set_fps fps clk] sets the [fps] of [clk] *)
val set_fps : float -> clock -> clock

(* [get_fps clk] is the current fps setting of [clk] *)
val get_fps : clock -> float

(* [starting_frame clk] updates [clk] so it's target is now 1/fps seconds in
 * the future *)
val starting_frame : clock -> clock

(*[is_time clk] returns true if [clk] has arrived at 1/fps in the future *)
val is_time : clock -> bool

(*[block_until clk] returns unit when [is_time clk] would return true *)
val block_until : clock -> unit

