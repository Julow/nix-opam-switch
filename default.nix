{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellApplication {
  name = "nix-opam-switch";
  runtimeInputs = with pkgs; [ gnused coreutils ];
  text = ''
    nix_script=${./nix-opam-switch.nix}
    ${builtins.readFile ./nix-opam-switch}
  '';
}
