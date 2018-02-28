open Printf
open Cryptokit

type 'a tree =
  | Leaf of 'a
  | Branch of 'a tree * 'a tree

let new_tree gen_kwd =
  let hash_str = hash_string (Hash.sha2 256) gen_kwd in
  Leaf hash_str

let rec fringe = function
  | Leaf x -> [x]
  | Branch (left, right) -> fringe left @ fringe right

let same_fringe t1 t2 = fringe t1 = fringe t2
  
let unfringe l =
  let rec aux l' tree =
    match l' with
    | [] -> tree
    | x::[] -> Branch (tree, Leaf x)
    | x::xs -> aux xs (Branch (tree, Leaf x))
  in
  match l with
  | [] -> Leaf ""
  | y::[] -> Leaf y
  | y::ys -> aux ys (Leaf y)

let append_tree tree kwd_l kwd_r =
  let flattened = fringe tree in
  let new_flattened = kwd_l :: kwd_r :: flattened in
  unfringe new_flattened

let peek_all tree =
  let flattened = fringe tree in
  let len = List.length flattened in
  let rec aux l acc1 acc2 =
    if acc1 <= 0
    then ()
    else
      match l with
      | [] -> print_newline ()
      | x::xs -> printf "%d: %S\n" acc2 x; aux xs (acc1 - 1) (acc2 + 1)
  in aux flattened len 0
