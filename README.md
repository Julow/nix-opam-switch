# nix-opam-switch

Create and maintain Opam switches where the compiler and tools are built by Nix.

This brings several advantages:

- The compiler and the tools might be fetched from Nix's online cache.
  Creating a switch is much faster.

- Several switches can share the same compiler and tools,
  reducing disk usage.

- Tools' dependencies are not installed in the switch.
  They cannot interfere with the projects' dependencies.

- On NixOS, regular updates and automatic GC can make Opam switches expire.
  The compiler and other binaries contain absolute paths to C libraries that are not recorded as GC roots and eventually disappear.

The tools installed alongside the compiler are:

- Merlin
- ocp-indent
- OCamlformat

## Install

This tools rely on Nix and Opam to be installed.
Nix is also required for the installation.

Installation from source (useful to hack on the code):

```bash
git clone https://github.com/Julow/nix-opam-switch
cd nix-opam-switch
nix-env -if .
```

Or by saving this to a file and running `nix-env -if the_file.nix`:

```nix
{ pkgs ? import <nixpkgs> { } }:

pkgs.callPackage (pkgs.fetchgit {
  url = "https://github.com/Julow/nix-opam-switch";
  rev = "efeceac93235d3b989bca55a3cde06467f10bf8f";
  sha256 = "sha256-H2RsRcQTPI23ggjDmghqbw/3oVqNcEYMdf1IKckkr2Y=";
}) { }
```

`nix-env` can be repeated to update the package.

## Usage

### Local switch

This will create a local Opam switch with a recent version of OCaml, Merlin, ocp-indent and OCamlformat installed:

```bash
$ nix-opam-switch create .
```

It's possible to specify a version for OCaml. The available versions can be queried with:

```bash
$ nix-opam-switch list-available
...
4.14
5.0
$ nix-opam-switch create . 5.0
```

## Global switch

Global switches can be created like this:

```bash
$ nix-opam-switch create 4.14
$ nix-opam-switch create 4.14-foo 4.14
$ nix-opam-switch create 4.14-foo # Shortcut for the previous command
```

### Re-installing OCamlformat

It can be useful to update the version of OCamlformat without removing the switch and starting from scratch.
This command will read `.ocamlformat` to detect which version to install:

```bash
$ nix-opam-switch ocamlformat
```

It's possible to specify a version:

```bash
$ nix-opam-switch ocamlformat 0.24.1
```
