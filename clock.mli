type time_t = int

(*[get_time] returns the current time*)
val get_time : unit -> time_t

(*[is_time] returns true if the inputted time matches the time on the machine*)
val is_time : time_t -> bool