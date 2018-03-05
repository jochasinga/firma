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

let node_of_tx tx = if String.length tx > 0 then Node (tx, Leaf, Leaf) else Leaf

let tree_of_txs txs =
  let nodes = List.map node_of_tx txs in
  match nodes with
  | [] -> Leaf
  | [x] -> x
  | x::xs ->
    let empty = Leaf
    and tries =
      (**
       * 0 -> Merkle Root
       * 1 -> End of intermediate level
       * 2 -> Ongoing intermediate level
       *)

      (** TODO: Find a better way than tries, or at least come up with a better variable name. *)
      match nodes with [] -> 0 | [_] | [_; _] -> 1 | _ -> 2
  in
  (* printf "Starting tries: %d\n" tries; *)
  let rec aux ?(tries=tries) ?(next=[]) tree' nodes' =
    match nodes' with
    | [] -> Leaf
    | [x] -> (
      (** Merkle root *)
      if tries = 0 then (printf "last tries: %d\n" tries; x)
      else
      (** Handle a widow child transaction *)
        match x with
        | Leaf -> tree'
        | Node (x_data, _, _) ->
          let parent_data = x_data ^ x_data in
          let parent = Node (parent_data, x, x) in
          aux ~tries:(tries-1) tree' (next @ [parent])
      )
    (** Ongoing ... *)
    | a :: b :: rest -> (
      (* printf "tries: %d\n" tries; *)
      match a, b with
      | Leaf, Leaf -> empty
      | Node (a_data, _, _), Leaf ->
        let parent = Node (a_data ^ a_data, a, a) in
        if List.length rest = 0
        then aux ~tries:(tries-1) tree' (next @ [parent])
        else aux ~next:(next @ [parent]) tree' rest

      | Leaf, Node (b_data, _, _) ->
        let parent = Node (b_data ^ b_data, b, b) in
        if List.length rest = 0
        then aux ~tries:(tries-1) tree' (next @ [parent])
        else aux ~next:(next @ [parent]) tree' rest

      | Node (a_data, _, _), Node (b_data, _, _) ->
        (* printf "Node %S, Node %S (tries: %d)\n" a_data b_data tries; *)
        let parent = Node (a_data ^ b_data, a, b) in
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
