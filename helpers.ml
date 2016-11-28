(* https://www.cs.cornell.edu/Courses/cs3110/2016fa/l/23-monads/rec.html *)
module Maybe = struct
  type 'a t = 'a option
  let return x = Some x 
  let bind m f = 
    match m with 
      | Some x -> f x 
      | None -> None
  let (>>=) = bind 
end

(* https://stackoverflow.com/questions/243864/what-is-the-ocaml-idiom-equivalent-to-pythons-range-function *)
(* make an int list with numbers i..j inclusive *)
let rec range i j = if i > j then [] else i :: (range (i+1) j)

(* https://stackoverflow.com/questions/3989776/transpose-of-a-list-of-lists *)
let rec transpose list = match list with
| []             -> []
| []   :: xss    -> transpose xss
| (x::xs) :: xss ->
    (x :: List.map List.hd xss) :: transpose (xs :: List.map List.tl xss)

(* applies f to x a total of i times. i >= 0 *)
let rec foldi i f x = if i==0 then x else foldi (i-1) f (f x)

(* https://stackoverflow.com/questions/15095541/how-to-shuffle-list-in-on-in-ocaml *)
(* randomizes a list *)
(* let shuffle d = *)
(*     let nd = List.map (fun c -> (Random.bits (), c)) d in *)
(*     let sond = List.sort compare nd in *)
(*     List.map snd sond *)

(* https://caml.inria.fr/pub/docs/manual-ocaml/libref/Array.html *)
let swap a i j =
  let t = a.(i) in
  a.(i) <- a.(j);
  a.(j) <- t

(* https://caml.inria.fr/pub/docs/manual-ocaml/libref/Array.html *)
let shuffle_array a =
  Array.iteri (fun i _ -> swap a i (Random.int (i+1))) a; a

let shuffle l = l |> Array.of_list |> shuffle_array |> Array.to_list

module IntIntHash =
  struct
    type t = int * int
    let equal i j = i=j
    let hash (a,b) = (a*1001+b) land max_int
  end

module IntIntHashtbl = Hashtbl.Make(IntIntHash)

module IntIntOrdered = struct
  type t = int * int
  let hash (x,y) = x*100001 + y
  let compare a b = Pervasives.compare (hash a) (hash b)
end

module IntIntSet = Set.Make(IntIntOrdered)

module IntOrdered = struct
  type t = int
  let compare = Pervasives.compare
end

module IntSet = Set.Make(IntOrdered)

let remove_dup (x : IntIntOrdered.t list) : IntIntOrdered.t list = x
  |> List.fold_left (fun acc x -> IntIntSet.add x acc) IntIntSet.empty
  |> IntIntSet.elements

