type 'a tree = Leaf | Node of 'a * 'a tree * 'a tree

val fringe : 'a tree -> 'a list
val new_tree : 'a list -> 'a tree
val insert : 'a -> 'a tree -> 'a tree
val mem : 'a -> 'a tree -> bool
val peek_all : string tree -> unit
