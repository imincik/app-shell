#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") -a "app1,app2,..." -c "command"

Create simple shell environment containing specified applications.

Available options:
-h, --help      Print this help and exit.
-a, --apps      Comma separated list of apps to activate in shell.
-c, --command   Command to run once shell is ready.
EOF
  exit
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  command=""
  
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -a | --apps)
      apps="${2-}"
      shift
      ;;
    -c | --command)
      command="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # Check required parameters
  [[ -z "${apps-}" ]] && die "Missing list of apps."

  return 0
}

parse_params "$@"


# Create app shell
if [ -n "${command-}" ]; then
  activate=$(nix build --print-out-paths --file default.nix --argstr apps "$apps" --argstr command "$command")
else
  activate=$(nix build --print-out-paths --file default.nix --argstr apps "$apps")
fi

$activate
