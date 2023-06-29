{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellApplication {
  name = "nix-opam-switch";
  text = ''
    nix_script=${./nix-opam-switch.nix}
    ${builtins.readFile ./nix-opam-switch}
  '';
}
