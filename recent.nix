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

in {
  ocamlPackages_per_version = find_ocamlPackages_version
    (pkgs.callPackage (recent_nixpkgs + "/pkgs/top-level/ocaml-packages.nix") { })
    // find_ocamlPackages_version pkgs.ocaml-ng;
}
