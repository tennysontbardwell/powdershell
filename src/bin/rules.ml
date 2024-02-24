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
    show : bool;
  }

type rules_t = ((name_t, elem_rules_t) Hashtbl.t) * name_t list

let gen_rules r_lst : rules_t = 
    let name_lst = List.map (fun (n,_) -> n ) r_lst in 
    let ht = Hashtbl.create 40 in 
    let add_to_ht (a, b) = Hashtbl.add ht a b in
    List.iter add_to_ht r_lst; (ht, name_lst)

let lookup_rule (tbl, _) s = Hashtbl.find tbl s 

let get_name_lst (_,name_lst) = name_lst
