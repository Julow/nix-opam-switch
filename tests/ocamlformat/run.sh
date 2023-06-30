nix-opam-switch create .
eval `opam env`
default_ver=$(ocamlformat --version)

nix-opam-switch ocamlformat 0.23.0
[[ $(ocamlformat --version) = "0.23.0" ]]

nix-opam-switch ocamlformat default
[[ $(ocamlformat --version) = "$default_ver" ]]

echo "version = 0.23.0 # comment" > .ocamlformat
nix-opam-switch ocamlformat
[[ $(ocamlformat --version) = "0.23.0" ]]
