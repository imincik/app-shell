#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") --app app1,app2,... -- [command]

Create simple shell environment containing specified applications.

Available options:
-h, --help            Print this help and exit.
-a, --apps            Comma separated list of apps to enable on PATH.
-p, --python-packages Comma separated list of Python packages to
                      enable on PYTHONPATH.
-v, --verbose         Run in verbose mode.

command               Command to execute in shell.
EOF
  exit
}

verbose_msg() {
  if [ -n "${verbose-}" ]; then
    echo >&2 -e "INFO: ${1-}"
  fi
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
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) verbose=1;;
    -a | --apps)
      apps="${2-}"
      shift
      ;;
    -p| --python-packages)
      python_packages="${2-}"
      shift
      ;;
    --)
      command=("${@:2}")
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  return 0
}
parse_params "$@"

# Create app shell command
cmd="nix build --print-out-paths --file default.nix"

if [ -n "${apps-}" ]; then
  cmd+=" --argstr apps $apps"
fi

if [ -n "${python_packages-}" ]; then
  cmd+=" --argstr pythonPackages $python_packages"
fi

if [ -n "${command-}" ]; then
  c=(--argstr command \'"${command[*]}"\')
  cmd+=" "
  cmd+=${c[*]}
fi

# Activate shell
verbose_msg "nix command: $cmd"
activate=$(eval "$cmd")
verbose_msg "activate script: $activate"
$activate
