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

(* https://caml.inria.fr/pub/docs/manual-ocaml/libref/Array.html *)
(* swaps two indexes of an array *)
let swap a i j =
  let t = a.(i) in
  a.(i) <- a.(j);
  a.(j) <- t

(* https://caml.inria.fr/pub/docs/manual-ocaml/libref/Array.html *)
(* uses [swap], does a quick, linear time, 'shuffle' (mix up of order) *)
let shuffle_array a =
  Array.iteri (fun i _ -> swap a i (Random.int (i+1))) a; a

(* https://caml.inria.fr/pub/docs/manual-ocaml/libref/Array.html *)
(* uses [shuffle_array] to shuffle a list *)
let shuffle l = l |> Array.of_list |> shuffle_array |> Array.to_list

(* https://stackoverflow.com/questions/21674947/ocaml-deoptionalize-a-list-is-there-a-simpler-way *)
(* This converts an a' option list to a' list, removing the nones *)
let deoptionalize l = 
    List.concat @@ List.map (function | None -> [] | Some x -> [x]) l

