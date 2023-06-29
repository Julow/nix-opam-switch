{ ocaml_version ? null, pkgs ? import <nixpkgs> { } }:

with pkgs.lib;

let
  ocaml_version_of_pkgs = ocamlPkgs: ocamlPkgs.ocaml.meta.branch;

  ocamlPackages_per_version = mapAttrs'
    (_: ocamlPkgs: nameValuePair (ocaml_version_of_pkgs ocamlPkgs) ocamlPkgs)
    (filterAttrs (n: _: hasPrefix "ocamlPackages_" n) pkgs.ocaml-ng);

  mk_switch = ocamlPkgs:
    pkgs.runCommandLocal "opam-switch-${ocaml_version_of_pkgs ocamlPkgs}" { } ''
      mkdir -p "$out"
      ocaml=${ocamlPkgs.ocaml}
      cp -sPr "$ocaml/"{bin,lib} "$out"
      cp -sPr "$ocaml/share/man" "$out"
    '';

in {
  list-available = mapAttrsToList (v: _: v) ocamlPackages_per_version;

  create = mk_switch (getAttr ocaml_version ocamlPackages_per_version);
}
