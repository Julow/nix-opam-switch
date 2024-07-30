{ lib, ocamlPackages, ... }:

# Files in this directory (except this one) are copied from nixpkgs.
# Do not modify them.

rec {
  ocamlformat_versions = [
    "0.19.0"
    "0.20.0"
    "0.20.1"
    "0.21.0"
    "0.22.4"
    "0.23.0"
    "0.24.0"
    "0.24.1"
    "0.25.1"
    "0.26.0"
    "0.26.1"
    "0.26.2"
  ];

  ocamlformat = ocamlPackages.callPackage ocamlformat/ocamlformat.nix {
    inherit ocamlformat-lib;
  };

  ocamlformat-lib =
    ocamlPackages.callPackage ocamlformat/ocamlformat-lib.nix { };
}
