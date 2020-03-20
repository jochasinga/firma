(lang dune 2.4)
(name api_server)

(generate_opam_files true)

(version 0.1.0)

(authors "Joe Chasinga")
(license MIT)

(source (uri "git+https://github.com/jochasinga/btc-merkle.git"))
(maintainers "jo.chasinga@gmail.com")
(homepage "https://github.com/jochasinga/btc-merkle")

(package
 (name api_server)
 (synopsis "API server for the merkle hash tree")
 (description "API server for the merkle hash tree")
 (depends
  ;; General system deps
  (dune (>= 2))
  (ocaml (>= 4.07.0))

  ;; Standard library replacement
  (core (>= 0.12.2))

  ;; Networking
  (cohttp (>= 2.5.1))
  (async (>= 0.13.0))
  (cohttp-async (>= 2.5.1))
  (cryptokit (>= 1.14))
  (yojson (>= 1.7.0))

  ;; Dev dependencies
  (utop :dev)
  (merlin :dev)
  (ocamlformat :dev)
  (ocp-indent :dev)
  (tuareg :dev)
  (alcotest :dev)
  (ounit2 :dev)))


       
