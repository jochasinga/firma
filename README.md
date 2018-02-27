# annihilation

Implementation of a Merkle tree

# setup

Find and link `cryptokit`

```bash

$ ocamlfind ocamlc -package cryptokit -c merkle.ml

```

then try loading `merkle.cmo` on toplevel:

```bash

utop # #load "merkle.cmo";;
utop # open Merkle;;

```

Instruction [here](http://projects.camlcity.org/projects/dl/findlib-1.2.6/doc/guide-html/quickstart.html) is awesome
for linking libraries.
