type 'a tree

val fringe : 'a tree -> 'a list
val unfringe : string list -> string tree
val new_tree : string -> string tree
val append_tree : string tree -> string tree -> string tree
val peek_all : string tree -> unit
