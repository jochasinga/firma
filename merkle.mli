type 'a tree = Leaf | Node of 'a * 'a tree * 'a tree
type payload = string * string

val fringe : 'a tree -> 'a list
val new_tree : 'a list -> 'a tree
val new_hashtree : string list -> payload tree
val insert : 'a -> 'a tree -> 'a tree
val insert_hashpair : string -> payload tree -> payload tree
val mem : 'a -> 'a tree -> bool
val peek_all : string tree -> unit
val peek_pair_all : payload tree -> unit
