# annihilation

Implementation of a Merkle tree

# setup

Compile the module

```bash

$ ocamlc -c merkle.ml

```

Find and link `cryptokit`

```bash

$ ocamlfind ocamlc -package cryptokit -c merkle.ml

```

Instruction [here](http://projects.camlcity.org/projects/dl/findlib-1.2.6/doc/guide-html/quickstart.html) is awesome
for linking libraries.

then load `merkle.cmo` on toplevel:

```bash

utop # #load "merkle.cmo";;
utop # open Merkle;;

```

## example

```ocaml

(** Print out all the tree's nodes *)
let () = 
  let mtree = tree_of_txs ["A"; "B"; "C"; "D"] in peek_all mtree
  
```

Find interface in [merkle.mli](./merkle.mli).

# WIP




