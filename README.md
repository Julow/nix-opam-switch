# nix-opam-switch

Create and maintain Opam switches where the compiler and tools are built by Nix.

This brings several advantages:

- Several switches can share the same compiler and tools.
  Reduces disk usage and makes switch creation potentially instant.

- The compiler and the tools might be fetched from Nix's online cache.
  If the compiler have not been built before, there's a chance that it could be
  fetched in seconds.

- Tools' dependencies are not installed in the switch.
  They cannot interfere with the projects' dependencies.

- Switches created by this tool do not expire on NixOS.
  The compiler and other binaries contain absolute paths to C libraries that
  are not recorded as GC roots and are eventually collected.

The tools installed alongside the compiler are:

- Merlin
- ocp-indent
- OCamlformat (with version specified in `./.ocamlformat`)

## Install

This tool relies on Nix and Opam to be also installed, they are not part of the
closure to avoid messing up with their mutable states.

Save this to a file and run `nix-env -if the_file.nix`:

```nix
{ pkgs ? import <nixpkgs> { } }:

# Or use the following in your NixOS configuration, nixpkgs overlay, etc..
pkgs.callPackage (pkgs.fetchgit {
  url = "https://github.com/Julow/nix-opam-switch";
  rev = "d9035b22b3e362210e190bab36f58fd18743992e";
  sha256 = "sha256-svGlLtYysrgNA3/E1kWsgDvGU51lAXdH8z7qIn/2tD0=";
}) { }
```

Or installation from source (useful to hack on the code):

```bash
git clone https://github.com/Julow/nix-opam-switch
cd nix-opam-switch
nix-env -if .
```

`nix-env` can be repeated to update the package.

## Usage

### Local switch

To create a local switch with a recent version of OCaml, Merlin, ocp-indent and OCamlformat installed:

```bash
$ nix-opam-switch create .
```

To create a local switch with a specific version of OCaml:

```bash
$ nix-opam-switch list-available
...
4.14
5.0
$ nix-opam-switch create . 5.0
```

## Global switch

To create a global switch:

```bash
$ nix-opam-switch create 4.14
$ nix-opam-switch create 4.14-foo 4.14
$ nix-opam-switch create 4.14-foo # Shortcut for the previous command
```

### Re-installing OCamlformat

To install the version of OCamlformat specified by the `.ocamlformat` in the
current directory:

```bash
$ nix-opam-switch ocamlformat
```

To install a specified version of OCamlformat:

```bash
$ nix-opam-switch ocamlformat 0.24.1
```
