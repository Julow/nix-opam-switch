nix-opam-switch create 4.14

# Binaries are as expected
prefix=$(opam var prefix)
for bin in $prefix/nix-roots/switch/bin/*; do
  [[ $(readlink "$prefix/bin/${bin##*/}") = $(readlink "$bin") ]]
done

# ocaml-system has been installed
opam list --installed ocaml-system &>/dev/null
