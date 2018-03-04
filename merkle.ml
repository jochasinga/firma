open Printf
open Cryptokit

type payload = string * string
type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree

let insert x s = Node (x, Leaf, s)
let insert_left x s = Node (x, s, Leaf)
let insert_right x s = Node (x, Leaf, s)

let insert_hashpair = fun x s ->
  let pair = x, hash_string (Hash.sha2 256) x in Node (pair, Leaf, s)

let rec new_tree: ('a list -> 'a tree) = fun l ->
  let empty = Leaf in
  match l with
  | [] -> empty
  | x :: l' -> insert x (new_tree l')

let create_tree_from_list nodes =
  match nodes with
  | [] -> Leaf
  | [x] -> x
  | x::xs ->
  let empty = Leaf
  and tries =
    match nodes with
    | [] -> 0
    | x::[] -> 1
    | x::xs -> (
      if List.length nodes mod 2 = 0
      then List.length nodes
      else List.length nodes + 1 ) / 2 in
    printf "tries left: %d\n" tries;
  let rec aux ?(tries=tries) ?(next=[]) tree' nodes' =
    match nodes' with
    (** This case should never be reached. *)
    | [] -> Leaf
    | [x] ->
      (** Merkle root is reached. *)
      if tries = 0 then x else
        (** Widow node reached. *)
        let Node (x_data, _, _) = x in
        let parent_data = x_data ^ x_data in
        let parent = Node (parent_data, x, x) in
        (* let Node (a, _, _) = x in printf "%S\n" a; *)
        aux ~tries:(tries-1) tree' (next @ [parent])

    (** start of a pass *)
    | a :: b :: rest -> (
      (*
      let Node (a_dat, _, _), Node (b_dat, _, _) = a, b in
      printf "%S, %S\n" a_dat b_dat;
      *)
      match a, b with
      | Leaf, Leaf -> empty
      | Node (a_data, _, _), Leaf ->
        let parent_data = a_data ^ a_data in
        let parent = Node (parent_data, a, a) in
        let Node (data, _, _) = List.hd next in
        (* printf "1: (node, leaf) -> %S\n" data; *)
        if List.length rest = 0
        then aux ~tries:(tries-1) tree' (next @ [parent])
        else aux ~next:(next @ [parent]) tree' rest

      | Leaf, Node (b_data, _, _) ->
        let parent_data = b_data ^ b_data in
        let parent = Node (parent_data, b, b) in

        if List.length rest = 0
        then aux ~tries:(tries-1) tree' (next @ [parent])
        else aux ~next:(next @ [parent]) tree' rest

      | Node (a_data, _, _), Node (b_data, _, _) ->
        let parent_data = a_data ^ b_data in
        let parent = Node (parent_data, a, b) in

        if List.length rest = 0
        then aux ~tries:(tries-1) tree' (next @ [parent])
        else aux ~next:(next @ [parent]) tree' rest
      )
  in aux Leaf nodes

let rec new_hashtree = fun l ->
  let empty = Leaf in
  match l with
  | [] -> empty
  | x :: l' -> insert_hashpair x (new_hashtree l')

let rec mem x = function
  | Leaf -> false
  | Node (y, left, right) ->
     x = y || mem x left || mem x right

let fringe: ('a tree -> 'a list) = fun t ->
  let rec aux acc t' =
    match t' with
    | Leaf -> acc
    | Node (x, left, right) ->
       x :: aux acc left @  aux acc right

  in aux [] t

let same_fringe t1 t2 = fringe t1 = fringe t2

let peek = function
  | Leaf -> ()
  | Node (s, _, _) -> printf "%S" s

let peek_left = function
  | Leaf -> ()
  | Node (_, left, _) ->
    match left with Leaf -> () | Node(s, _, _) -> printf "%S\n" s

let peek_right = function
  | Leaf -> ()
  | Node (_, _, right) ->
    match right with Leaf -> () | Node(s, _, _) -> printf "%S\n" s

let peek_all: (string tree -> unit) = fun t ->
  let flattened = fringe t in
  let len = List.length flattened in
  let rec aux l acc1 acc2 =
    if acc1 <= 0
    then ()
    else
      match l with
      | [] -> print_newline ()
      | x::xs -> printf "%d: %S\n" acc2 x; aux xs (acc1 - 1) (acc2 + 1)
  in aux flattened len 0

let peek_pair_all: (payload tree -> unit) = fun t ->
  let flattened = fringe t in
  let len = List.length flattened in
  let rec aux l acc1 acc2 =
    if acc1 <= 0
    then ()
    else match l with
         | [] -> print_newline ()
         | x::xs ->
            begin
              let a, b = x in
              printf "%d: (%S, %S)\n" acc2 a b;
              aux xs (acc1 - 1) (acc2 + 1)
            end
  in aux flattened len 0
