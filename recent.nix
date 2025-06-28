{ pkgs, lib }:

# Finds more recent versions of OCaml and tools when they are not available in
# 'pkgs'.
with lib;

let
  # TODO: Fetch something when I have network
  recent_nixpkgs = fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/6ddf8ff6929b9f6165ec032a715e1b0904cb1716.tar.gz";
    sha256 = "1lzxx0djm9crpqvhcjv9yphn4g756794rvz4syv0gcj11aqyq0qc";
  };

  find_versioned_attributes = version_of_attr: prefix: attrs:
    mapAttrs' (name: val: nameValuePair (version_of_attr name val) val)
    (filterAttrs (n: _: hasPrefix prefix n) attrs);

  find_ocamlPackages_version = attrs:
    find_versioned_attributes (name: val:
      if name == "ocamlPackages" then "default" else val.ocaml.meta.branch)
    "ocamlPackages" attrs;

  find_ocamlformat_version = attrs:
    find_versioned_attributes
    (name: val: if name == "ocamlformat" then "default" else val.version)
    "ocamlformat" attrs;

  recent_ocaml-ng =
    pkgs.callPackage (recent_nixpkgs + "/pkgs/top-level/ocaml-packages.nix")
    { };

  # Some versions of OCamlformat should come from
  # [pkgs.ocaml-ng.ocamlPackages_4_14] only.
  ocamlformat_post_500 = attrs:
    find_ocamlformat_version (builtins.removeAttrs attrs [
      "ocamlformat_0_19_0"
      "ocamlformat_0_20_0"
      "ocamlformat_0_20_1"
      "ocamlformat_0_21_0"
      "ocamlformat_0_22_4"
      "ocamlformat_0_23_0"
      "ocamlformat_0_24_1"
      "ocamlformat_0_25_1"
      "ocamlformat_0_26_0"
      "ocamlformat_0_26_1"
      "ocamlformat_0_26_2"
    ]);

in {
  ocamlPackages_per_version = find_ocamlPackages_version (recent_ocaml-ng)
    // find_ocamlPackages_version pkgs.ocaml-ng;

  ocamlformat_versions = ocamlformat_post_500 recent_ocaml-ng.ocamlPackages
    // find_ocamlformat_version pkgs.ocaml-ng.ocamlPackages_4_14
    // ocamlformat_post_500 pkgs.ocaml-ng.ocamlPackages;
}
