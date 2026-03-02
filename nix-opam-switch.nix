{
  ocamlformat_version ? "", # Argument used in 'create'
  pkgs ? import <nixpkgs> { },
}:

with pkgs.lib;

let
  inherit (pkgs.callPackage ./recent.nix { })
    ocamlPackages_per_version
    ocamlformat_versions
    ;

  ocaml_version_of_pkgs = ocamlPkgs: ocamlPkgs.ocaml.meta.branch;

  get_ocamlformat_version =
    version:
    # If the specified version is not right, continue with a default version
    let
      v =
        if hasAttr version ocamlformat_versions then
          version
        else if version == "" then
          "default"
        else
          warn "OCamlformat version '${version}' unsupported, using 'default'." "default";
    in
    getAttr v ocamlformat_versions;

  # Returns '[ pkg ]' if the given package is available, '[]' otherwise.
  # A package is available if it evaluates successfully.
  if_available =
    name: pkg:
    let
      e = builtins.tryEval (pkg.outPath);
    in
    if e.success then
      [ e.value ]
    else
      warn "Package '${name}' is not available for this OCaml version." [ ];

  pkg_if_available =
    name: pkg:
    map (path: {
      inherit name path;
      inherit (pkg) version;
    }) (if_available name pkg);

  # Rewrite a Nix package to be installed as an Opam package.
  opam_package_of_path =
    {
      postBuild ? "",
    }:
    {
      name,
      version,
      path,
    }:
    pkgs.symlinkJoin {
      inherit name version;
      paths = [ path ];
      postBuild = ''
        sitelib=$out/lib/${name}/${version}/site-lib
        if [[ -d $sitelib ]]; then
          mv "$sitelib"/* "$out/lib"
          rm -r "$out/lib/${name}/${version}"
        fi
        if [[ -d "$out/share/man" ]]; then mv "$out/share/man" "$out/man"; fi
        ${postBuild}
      '';
    };

  namever = pkg: "${pkg.name}.${pkg.version}";

  # ocamlfind does this by shadowing the 'ocaml' binary, which is no longer
  # possible since we copy 'ocaml' into the 'bin/' directory.
  override_ocaml_toplevel =
    ocaml:
    pkgs.writeShellScript "ocaml" ''
      ${ocaml}/bin/ocaml -I "$OCAML_TOPLEVEL_PATH" "$@"
    '';

  mk_switch =
    ocamlPkgs:
    let
      ocamlformat = get_ocamlformat_version ocamlformat_version;

      ocaml_system =
        opam_package_of_path
          {
            postBuild = ''
              ln -sf "${override_ocaml_toplevel ocamlPkgs.ocaml}" "$out/bin/ocaml"
            '';
          }
          {
            name = "ocaml-system";
            path = ocamlPkgs.ocaml.outPath;
            inherit (ocamlPkgs.ocaml) version;
          };

      packages = [
        ocaml_system
      ]
      ++ map (opam_package_of_path { }) (concatLists [
        (pkg_if_available "merlin" ocamlPkgs.merlin)
        (pkg_if_available "ocp-indent" ocamlPkgs.ocp-indent)
        (pkg_if_available "ocamlformat" ocamlformat)
      ]);
    in

    pkgs.symlinkJoin {
      name = "opam-switch-${ocaml_version_of_pkgs ocamlPkgs}";
      paths = packages;
    };

in
{
  list-available = mapAttrsToList (v: _: v) ocamlPackages_per_version;
  list-ocamlformat = mapAttrsToList (v: _: v) ocamlformat_versions;

  # Opam switches mapped by OCaml versions. The version "default" maps to the
  # default version exposed in nixpkgs (which is not always the lastest).
  create = mapAttrs (_: mk_switch) ocamlPackages_per_version;

  # OCamlformat packages mapped by versions. The version "default" points to
  # the lastest, as defined in nixpkgs.
  # Result matches the hierarchy of an Opam switch.
  ocamlformat = mapAttrs (
    version: path:
    opam_package_of_path {
      name = "ocamlformat";
      inherit version path;
    }
  ) ocamlformat_versions;
}
