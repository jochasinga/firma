type 'a tree

val fringe : 'a tree -> 'a list
val unfringe : 'a option list -> 'a option tree
val new_tree : string -> 'a tree
val append_tree : 'a tree -> string -> string -> 'a tree
