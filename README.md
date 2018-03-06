# annihilation

Implementation of a Merkle Hash Tree based on the [Bitcoin Whitepaper](https://bitcoin.org/bitcoin.pdf).

## Testing on Ocaml's toplevel

Compile the module interface

```bash

$ ocamlc -c merkle.ml     # merkle.cmi

```

Find and link dependencies, then compile to module object file (`.cmo`)

```bash

$ ocamlfind ocamlc -package cryptokit,yojson -c merkle.ml

```

Instruction [here](http://projects.camlcity.org/projects/dl/findlib-1.2.6/doc/guide-html/quickstart.html) is awesome
for linking libraries.

then load `merkle.cmo` on Ocaml's toplevel / utop:

```bash

#load "merkle.cmo";;
open Merkle;;

```

## example

```ocaml

(** Print out all the tree's nodes *)

tree_of_txs ["A"; "B"; "C"; "D"] |> peek_all ;;

```

## Run JSON API server

Find the root directory where `api_server.ml`is located, then

```bash

$ corebuild api_server.native -pkg cohttp.async,yojson,cryptokit
$ ./api_server.native

```

If nothing goes wrong, you should see this being printed:

```bash

Listening for HTTP on port 8080
Try 'curl http://localhost:8080/merkle?txs=x,y,z'

```

The API server writes a JSON structure representing a binary Merkle tree created
from the input of transactions (`txs`).

## example

Provided transactions `A`, `B`, `C`, and `D`:

```bash

curl http://localhost:8080/merkle?txs=A,B,C,D

```
The JSON string being returned is

```json

{
  data: {
    hash: "ABCD",
    left: {
      hash: "AB",
      left: {
        hash: "A",
        left: null,
        right: null
      },
      right: {
        hash: "B",
        left: null,
        right: null
      }
    },
    right: {
      hash: "CD",
      left: {
        hash: "C",
        left: null,
        right: null
      },
      right: {
        hash: "D",
        left: null,
        right: null
      }
    }
  }
}

```

Read [merkle.mli](./merkle.mli) to find out more.

# WIP




