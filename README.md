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

Find the root directory where `api_server.ml`is located, then with [corebuild](https://github.com/janestreet/core):

```bash

$ corebuild api_server.native -pkg cohttp.async,yojson,cryptokit
$ ./api_server.native

```

or alternatively using [jbuild](https://github.com/ocaml/dune) is very simple:

```bash

$ jbuild build api_server.exe
$ ./_build/default/api_server.exe

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

curl http://localhost:8080/merkle?txs=A,B,C,D&debug=true

```
The JSON string being returned is

```json

{
  "data": {
    "hash": "ABCD",
    "children": [
      {
        "hash": "AB",
        "children": [
          {
            "hash": "A",
            "children": []
          },
          {
            "hash": "B",
            "children": []
          }
        ]
      },
      {
        "hash": "CD",
        "children": [
          {
            "hash": "C",
            "children": []
          },
          {
            "hash": "D",
            "children": []
          }
        ]
      }
    ]
  }
}

```
Setting `debug` query parameter to anything other than `true` or leave empty
will default to `debug=false` and hash strings are returned instead.

JSON with `null` data will be returned if the number of `tx` is not a power of two.y

Read [merkle.mli](./merkle.mli) to find out more.

# WIP




