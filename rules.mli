type name_t = string

type probability_t = float

type move_option_t = (int * int) list * probability_t

type interaction_t = Change of name_t * name_t * probability_t

type transform_t = name_t * probability_t

type elem_rules_t =
  {
    (* red green blue *)
    color : int * int * int;
    lifespan : int;
    display : string;
    shimmer : int;
    interactions : interaction_t list;
    movements : move_option_t list;
    density : int;
    transforms : transform_t list;
  }

type rules_t = (name_t, elem_rules_t) Hashtbl.t

val gen_rules : (name_t * elem_rules_t) list -> rules_t

val lookup_rule : rules_t -> string -> elem_rules_t

(* [validate rules] determins whether or not [rules] is a vaild *)
val validate : rules_t -> bool
