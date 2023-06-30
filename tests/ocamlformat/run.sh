echo "version=0.23.0#comment" > .ocamlformat
nix-opam-switch create .
eval `opam env`
[[ $(ocamlformat --version) = "0.23.0" ]]

# The default is above 0.23.0 at the time of writing and will only increase
nix-opam-switch ocamlformat default
! [[ $(ocamlformat --version) = "0.23.0" ]]

echo "version = 0.23.0 # comment" > .ocamlformat
nix-opam-switch ocamlformat
[[ $(ocamlformat --version) = "0.23.0" ]]
