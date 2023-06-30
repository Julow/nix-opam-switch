nix-opam-switch create .

[[ $(readlink "_opam/bin/ocaml") = $(readlink "_opam/nix-roots/switch/bin/ocaml") ]]
opam list --switch=. --installed ocaml-system &>/dev/null
