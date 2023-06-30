set -e

# Run the tests passed as arguments, defaults to all.
if [[ $# -eq 0 ]]; then set "$(dirname "$0")"/*/run.sh; fi

for t in "$@"; do
  echo; echo "### $t"
  ( cd "${t%/run.sh}" && bash -e run.sh )
done
