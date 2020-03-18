open Printf
open Cryptokit
(* open Yojson *)

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

let is_perfect_power_of a b =
  if a = 0 || a = 1 || a mod b <> 0 then false
  else
  let rec aux a' =
    if a' = 1 then true
    else if a' mod b <> 0 then false
    else aux (a' / b)
  in aux a

let is_perfect_power_of_two n = is_perfect_power_of n 2

let is_one_lt_perfect_power_of_two n = is_perfect_power_of_two (n + 1)

let hash_str_of_tx tx =
  let transform = Hexa.encode () in
  transform_string transform (hash_string (Hash.sha2 256) tx)

let node_of_tx ?(debug = true) ?(left = Leaf) ?(right = Leaf) tx =
  if String.length tx > 0 then Node ((if debug then tx else hash_str_of_tx tx), left, right) else Leaf

let tree_of_txs ?(debug = true) txs =
  if not (
    List.length txs |> is_perfect_power_of_two
    || List.length txs |> is_one_lt_perfect_power_of_two
    )
  then Leaf else

  let nodes = List.map (node_of_tx ~debug:debug) txs in
  match nodes with
  | [] -> Leaf
  | [x] -> x
  | _::_ ->
    let empty = Leaf
    and tries =
      (*
       * 0 -> Merkle Root
       * 1 -> End of intermediate level
       * 2 -> Ongoing intermediate level
       *)

      (* TODO: Find a better way than tries, or at least come up with a better variable name. *)
      match nodes with [] -> 0 | [_] | [_; _] -> 1 | _ -> 2
  in
  (* printf "Starting tries: %d\n" tries; *)
  let rec aux ?(tries=tries) ?(next=[]) tree' nodes' =
    match nodes' with
    | [] -> Leaf
    | [x] -> (
      (* Merkle root *)
      if tries = 0 then (printf "last tries: %d\n" tries; x)
      else
      (* Handle a widow child transaction *)
        match x with
        | Leaf -> tree'
        | Node (x_data, _, _) ->
          (* let parent_data = if debug then x_data ^ x_data else hash_str_of_tx (x_data ^ x_data) in *)
          (* let parent = Node (parent_data, x, x) in *)
          let parent = node_of_tx ~debug:debug ~left:x ~right:x (x_data ^ x_data) in
          aux ~tries:(tries-1) tree' (next @ [parent])
      )
    (* Ongoing ... *)
    | a :: b :: rest -> (
      (* printf "tries: %d\n" tries; *)
      match a, b with
      | Leaf, Leaf -> empty
      | Node (a_data, _, _), Leaf ->
        (* let parent = Node (a_data ^ a_data, a, a) in *)
        let parent = node_of_tx ~debug:debug ~left:a ~right:a (a_data ^ a_data) in
        if List.length rest = 0
        then aux ~tries:(tries-1) tree' (next @ [parent])
        else aux ~next:(next @ [parent]) tree' rest

      | Leaf, Node (b_data, _, _) ->
        (* let parent = Node (b_data ^ b_data, b, b) in *)
        let parent = node_of_tx ~debug:debug ~left:a ~right:b (b_data ^ b_data) in
        if List.length rest = 0
        then aux ~tries:(tries-1) tree' (next @ [parent])
        else aux ~next:(next @ [parent]) tree' rest

      | Node (a_data, _, _), Node (b_data, _, _) ->
        (* printf "Node %S, Node %S (tries: %d)\n" a_data b_data tries; *)
        (* let parent = Node (a_data ^ b_data, a, b) in *)
        let parent = node_of_tx ~debug:debug ~left:a ~right:b (a_data ^ b_data) in
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

let rec peek_tree = function
  | Leaf ->  ()
  | Node (h, left, right) ->
    printf "%s\n" h;
    peek_tree left; peek_tree right

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

let json_of_tree tree =
  `Assoc [
    ("data", (
    let rec aux tree' =
      match tree' with
      | Leaf -> `Null
      | Node (hash, left, right) ->
        (
        match aux left, aux right with
        | `Null, `Null -> []
        | `Null, right -> [right]
        | left, `Null -> [left]
        | left, right -> [left; right]
        )
        |> (fun children -> `Assoc [
              ("hash", `String hash);
              ("children", `List children)])
    in aux tree ))
  ] |> Yojson.Basic.to_string

  (* Example of JSON structure
  `Assoc [
      ("data", `Assoc [
        ("hash", `String "ABCD");
        ("left", `Assoc [
          ("hash", `String "AB");
          ("left", `Assoc [("hash", `String "A")]);
          ("right", `Assoc [("hash", `String "B")])
        ]);
        ("right", `Assoc [
          ("hash", `String "CD");
          ("left", `Assoc [("hash", `String "C")]);
          ("right", `Assoc [("hash", `String "D")])
        ])
      ])
    ]
  *)

module Tree = struct
  type t = string tree
  let of_tx = node_of_tx ~debug:false
  let of_txs = tree_of_txs
  let to_json = json_of_tree
end
