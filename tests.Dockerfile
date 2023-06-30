FROM nixos/nix
RUN nix-channel --update

# Install Opam
RUN nix-env -i opam patch gnumake diffutils
RUN opam init --bare --yes

# Warmup caches
RUN nix-build --no-out-link -E \
  'with import <nixpkgs> {}; writeShellApplication { name = "dummy"; text = ""; }'
RUN nix-build --no-out-link '<nixpkgs>' -A ocamlPackages.ocaml \
  -A ocamlPackages.merlin -A ocamlPackages.ocp-indent -A ocamlformat \
  -A ocamlformat_0_23_0

WORKDIR /home

# Build the project
COPY . .
RUN nix-env -if .
