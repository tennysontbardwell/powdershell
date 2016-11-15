type name_t = string

type probability_t = float

type move_option_t = (int * int) * probability_t

type interaction_t = Change of name_t * probability_t | Duplicate of name_t

type elem_rules_t = {inter : (name_t * interaction_t) list; movement : move_option_t list; density : int}

type rules_t = (name_t * elem_rules_t) list

(*[get_rules] returns the current rules of the game.*)
val get_rules : unit -> rules_t
