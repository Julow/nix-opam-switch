#!/usr/bin/env bash
set -e

# To ensure reproducibility and to avoid messing up with the home directory and
# Opam's state, the tests are run in a Docker container.

docker build -t nix-opam-switch-test -f tests.Dockerfile .
docker run --rm nix-opam-switch-test bash tests/run.sh "$@"
