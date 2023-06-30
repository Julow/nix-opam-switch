{ ocaml_version ? null, pkgs ? import <nixpkgs> { } }:

with pkgs.lib;

let
  ocaml_version_of_pkgs = ocamlPkgs: ocamlPkgs.ocaml.meta.branch;

  ocamlPackages_per_version = mapAttrs'
    (_: ocamlPkgs: nameValuePair (ocaml_version_of_pkgs ocamlPkgs) ocamlPkgs)
    (filterAttrs (n: _: hasPrefix "ocamlPackages_" n) pkgs.ocaml-ng);

  # Rewrite a package to be compatible with the directory hierarchy of an Opam
  # switch
  switch_of_paths = name: ocaml_version: paths:
    pkgs.symlinkJoin {
      inherit name paths;
      postBuild = ''
        sitelib=$out/lib/ocaml/${ocaml_version}/site-lib
        if [[ -d $sitelib ]]; then
          mv "$sitelib"/* "$out/lib"
          rm -r "$out/lib/ocaml/${ocaml_version}"
        fi
        mv "$out/share/man" "$out/man"
        rm -rf "$out/"{nix-support,include}
      '';
    };

  mk_switch = ocamlPkgs:
    switch_of_paths "opam-switch-${ocaml_version_of_pkgs ocamlPkgs}"
    ocamlPkgs.ocaml.version [
      ocamlPkgs.ocaml
      ocamlPkgs.merlin
      ocamlPkgs.ocp-indent
      pkgs.ocamlformat
    ];

in {
  list-available = mapAttrsToList (v: _: v) ocamlPackages_per_version;

  create = mk_switch (getAttr ocaml_version ocamlPackages_per_version);

  # OCamlformat packages mapped by versions. The version "default" points to
  # the lastest, as defined in nixpkgs.
  # Result matches the hierarchy of an Opam switch.
  ocamlformat = let
    ocamlformat_pkgs =
      # Remove implicit attributes like "overrideDerivation"
      filterAttrs (n: _: hasPrefix "ocamlformat" n)
      (pkgs.callPackage "${pkgs.path}/pkgs/development/tools/ocaml/ocamlformat"
        { });
    ocamlformat_to_switch = n: pkg:
      let version = if n == "ocamlformat" then "default" else pkg.version;
      in nameValuePair version
      (switch_of_paths "ocamlformat-${version}" pkgs.ocaml.version pkg);
  in mapAttrs' ocamlformat_to_switch ocamlformat_pkgs;
}
