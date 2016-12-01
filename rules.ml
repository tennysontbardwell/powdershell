type name_t = string

type probability_t = float

type move_option_t = (int * int) list * probability_t

type interaction_t = Change of name_t * name_t * probability_t

type transform_t = name_t * probability_t

type grow_t = name_t * probability_t

type destroy_t = name_t * probability_t

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
    grow : grow_t list;
    destroy : destroy_t list;
    decay : probability_t;
  }

type rules_t = (name_t, elem_rules_t) Hashtbl.t

let gen_rules r_lst = 
    let ht = Hashtbl.create 40 in 
    let add_to_ht (a, b) = Hashtbl.add ht a b in
    List.iter add_to_ht r_lst; ht

let lookup_rule = Hashtbl.find

(* [validate rules] determins whether or not [rules] is a vaild *)
let validate _ = failwith "unimplemented"

