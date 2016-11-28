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

