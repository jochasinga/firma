type 'a tree

val fringe : 'a tree -> 'a list
val unfringe : 'a option list -> 'a option tree
val new_tree : string -> string tree
val append_tree : 'a option tree -> 'a option -> 'a option -> 'a option tree
