{ ocaml_version ? null, pkgs ? import <nixpkgs> { } }:

with pkgs.lib;

let
  ocaml_version_of_pkgs = ocamlPkgs: ocamlPkgs.ocaml.meta.branch;

  ocamlPackages_per_version = mapAttrs'
    (_: ocamlPkgs: nameValuePair (ocaml_version_of_pkgs ocamlPkgs) ocamlPkgs)
    (filterAttrs (n: _: hasPrefix "ocamlPackages_" n) pkgs.ocaml-ng);

  mk_switch = ocamlPkgs:
    pkgs.symlinkJoin {
      name = "opam-switch-${ocaml_version_of_pkgs ocamlPkgs}";
      paths = with ocamlPkgs; [ ocaml merlin ocp-indent ];
      postBuild = ''
        sitelib=$out/lib/ocaml/${ocamlPkgs.ocaml.version}/site-lib
        if [[ -d $sitelib ]]; then
          mv "$sitelib"/* "$out/lib"
          rm -r "$out/lib/ocaml/${ocamlPkgs.ocaml.version}"
        fi
        mv "$out/share/man" "$out/man"
        rm -r "$out/"{nix-support,include}
      '';
    };

in {
  list-available = mapAttrsToList (v: _: v) ocamlPackages_per_version;

  create = mk_switch (getAttr ocaml_version ocamlPackages_per_version);
}
