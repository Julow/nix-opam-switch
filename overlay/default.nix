{ lib, ocaml-ng, ... }:

with lib;

# Files in this directory (except this one) are copied from nixpkgs.
# Do not modify them.

let
  pre52 = rec {
    ocamlPackages = ocaml-ng.ocamlPackages_4_14;

    ocamlformat = ocamlPackages.callPackage ocamlformat/ocamlformat.nix {
      inherit ocamlformat-lib;
    };

    ocamlformat-lib =
      ocamlPackages.callPackage ocamlformat/ocamlformat-lib.nix { };

    versions = {
      "0.19.0" = ocamlformat.override { version = "0.19.0"; };
      "0.20.0" = ocamlformat.override { version = "0.20.0"; };
      "0.20.1" = ocamlformat.override { version = "0.20.1"; };
      "0.21.0" = ocamlformat.override { version = "0.21.0"; };
      "0.22.4" = ocamlformat.override { version = "0.22.4"; };
      "0.23.0" = ocamlformat.override { version = "0.23.0"; };
      "0.24.1" = ocamlformat.override { version = "0.24.1"; };
      "0.25.1" = ocamlformat.override { version = "0.25.1"; };
      "0.26.0" = ocamlformat.override { version = "0.26.0"; };
      "0.26.1" = ocamlformat.override { version = "0.26.1"; };
    };
  };

  post52 = rec {
    ocamlPackages = ocaml-ng.ocamlPackages_5_2;

    ocamlformat = ocamlPackages.callPackage ocamlformat/ocamlformat.nix {
      inherit ocamlformat-lib;
    };

    ocamlformat-lib =
      ocamlPackages.callPackage ocamlformat/ocamlformat-lib.nix { };

    versions = {
      "0.26.2" = ocamlformat.override { version = "0.26.2"; };
    };
  };

in

rec {
  # Versions of OCamlformat indexed by their version string.
  ocamlformat_versions = pre52.versions // post52.versions;

  ocamlformat_default = getAttr "0.26.2" ocamlformat_versions;
}
