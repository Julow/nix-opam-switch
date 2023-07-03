{ ocamlformat_version ? "" # Argument used in 'create'
, pkgs ? import <nixpkgs> { } }:

with pkgs.lib;

let
  ocaml_version_of_pkgs = ocamlPkgs: ocamlPkgs.ocaml.meta.branch;

  ocamlPackages_per_version = mapAttrs' (n: ocamlPkgs:
    let
      name = if n == "ocamlPackages" then
        "default"
      else
        ocaml_version_of_pkgs ocamlPkgs;
    in nameValuePair name ocamlPkgs)
    (filterAttrs (n: _: hasPrefix "ocamlPackages" n) pkgs.ocaml-ng);

  ocamlformat_per_version = mapAttrs' (n: pkg:
    let version = if n == "ocamlformat" then "default" else pkg.version;
    in nameValuePair version pkg)
  # Filter-out implicit attributes like "overrideDerivation"
    (filterAttrs (n: _: hasPrefix "ocamlformat" n)
      (pkgs.callPackage "${pkgs.path}/pkgs/development/tools/ocaml/ocamlformat"
        { }));

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
      ocamlformat = if hasAttr ocamlformat_version ocamlformat_per_version then
        getAttr ocamlformat_version ocamlformat_per_version
      else
        pkgs.ocamlformat;
    in switch_of_paths {
      name = "opam-switch-${ocaml_version_of_pkgs ocamlPkgs}";
      ocaml_version = ocamlPkgs.ocaml.version;
      paths =
        [ ocamlPkgs.ocaml ocamlPkgs.merlin ocamlPkgs.ocp-indent ocamlformat ];
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
    }) ocamlformat_per_version;
}
