open Cryptokit

type 'a tree =
  | Leaf of 'a
  | Branch of 'a tree * 'a tree

let new_tree gen_kwd =
  let hash_str = hash_string (Hash.sha2 256) gen_kwd in
  Leaf hash_str

let rec fringe : 'a tree -> 'a list = function
  | Leaf x -> [x]
  | Branch(left, right) -> fringe left @ fringe right

let unfringe l =
  let rec aux l' tree =
    match l' with
    | [] -> tree
    | x::[] -> Branch (tree, Leaf x)
    | x::xs -> aux xs (Branch (tree, Leaf x))
  in
  match l with
  | [] -> Leaf None
  | y::[] -> Leaf y
  | y::ys -> aux ys (Leaf y)

let append_tree tree kwd_l kwd_r =
    let flattened = fringe tree in
    let new_flattened = kwd_l :: kwd_r :: flattened in
    unfringe new_flattened
