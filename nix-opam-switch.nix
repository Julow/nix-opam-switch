{ ocamlformat_version ? "" # Argument used in 'create'
, pkgs ? import <nixpkgs> { } }:

with pkgs.lib;

let
  overlay = pkgs.callPackage ./overlay { };

  inherit (pkgs.callPackage ./recent.nix {}) ocamlPackages_per_version;

  ocaml_version_of_pkgs = ocamlPkgs: ocamlPkgs.ocaml.meta.branch;

  # Returns '[ pkg ]' if the given package is available, '[]' otherwise.
  # A package is available if it evaluates successfully.
  if_available = name: pkg:
    let e = builtins.tryEval (pkg.outPath);
    in if e.success then
      [ e.value ]
    else
      warn "Package '${name}' is not available for this OCaml version." [ ];

  # Rewrite a package to be compatible with the directory hierarchy of an Opam
  # switch
  switch_of_paths = { name, ocaml_version, paths, postBuild ? "" }:
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
        ${postBuild}
      '';
    };

  # ocamlfind does this by shadowing the 'ocaml' binary, which is no longer
  # possible since we copy 'ocaml' into the 'bin/' directory.
  override_ocaml_toplevel = ocaml:
    pkgs.writeShellScript "ocaml" ''
      ${ocaml}/bin/ocaml -I "$OCAML_TOPLEVEL_PATH" "$@"
    '';

  mk_switch = ocamlPkgs:
    let
      # If the specified version is not right, continue with a default version
      ocamlformat = if hasAttr ocamlformat_version overlay.ocamlformat_versions then
        getAttr ocamlformat_version overlay.ocamlformat_versions
      else
        overlay.ocamlformat_default;

      paths = concatLists [
        [ ocamlPkgs.ocaml ]
        (if_available "merlin" ocamlPkgs.merlin)
        (if_available "ocp-indent" ocamlPkgs.ocp-indent)
        (if_available "ocamlformat" ocamlformat)
      ];
    in switch_of_paths {
      name = "opam-switch-${ocaml_version_of_pkgs ocamlPkgs}";
      ocaml_version = ocamlPkgs.ocaml.version;
      inherit paths;
      postBuild = ''
        ln -sf "${override_ocaml_toplevel ocamlPkgs.ocaml}" "$out/bin/ocaml"
      '';
    };

in {
  list-available = mapAttrsToList (v: _: v) ocamlPackages_per_version;

  # Opam switches mapped by OCaml versions. The version "default" maps to the
  # default version exposed in nixpkgs (which is not always the lastest).
  create = mapAttrs (_: mk_switch) ocamlPackages_per_version;

  # OCamlformat packages mapped by versions. The version "default" points to
  # the lastest, as defined in nixpkgs.
  # Result matches the hierarchy of an Opam switch.
  ocamlformat = mapAttrs (v: pkg:
    switch_of_paths {
      name = "ocamlformat-${v}";
      ocaml_version = pkgs.ocaml.version;
      paths = [ pkg ];
    }) overlay.ocamlformat_versions;
}
