type 'a tree = Leaf | Node of 'a * 'a tree * 'a tree
type payload = string * string

val fringe : 'a tree -> 'a list
val new_tree : 'a list -> 'a tree
(* val node_of_tx : string -> string tree *)
val node_of_tx : ?debug:bool -> ?left:string tree -> ?right:string tree -> string -> string tree
(* val tree_of_txs : string list -> string tree *)
val tree_of_txs : ?debug:bool -> string list -> string tree
val new_hashtree : string list -> payload tree
val insert : 'a -> 'a tree -> 'a tree
val insert_hashpair : string -> payload tree -> payload tree
val mem : 'a -> 'a tree -> bool
val peek : string tree -> unit
val peek_all : string tree -> unit
val peek_left : string tree -> unit
val peek_right : string tree -> unit
val is_perfect_power_of : int -> int -> bool
val is_perfect_power_of_two : int -> bool
val is_one_lt_perfect_power_of_two : int -> bool
val peek_tree : string tree -> unit
val json_of_tree : string tree -> string
(*
val peek_pair_all : payload tree -> unit
val print_left_leaves : payload tree -> unit
val print_right_leaves : payload tree -> unit
*)

module Tree : sig
  type t
  val of_tx : ?left:t -> ?right:t -> string -> t
  val of_txs : ?debug:bool -> string list -> t
  val to_json : t -> string
end
