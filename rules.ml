type name_t = string

type probability_t = float

type move_option_t = (int * int) list * probability_t

type interaction_t = Change of name_t * name_t * probability_t

type elem_rules_t =
  {
    interactions : interaction_t list;
    movements : move_option_t list;
    density : int
  }

type rules_t = (name_t * elem_rules_t) list

(* [validate rules] determins whether or not [rules] is a vaild *)
let validate _ = failwith "unimplemented"

