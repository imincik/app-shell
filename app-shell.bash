#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck disable=SC2034
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [options] -- [command]

Create a temporary shell environment containing specified applications.

Available options:

-n, --nixpkgs         Nixpkgs tarball to use.
                      Default:
                        https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
                      Example:
                        https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz

-a, --apps            Comma separated list of applications to enable on PATH.
                      Example: gdal,qgis

C language support:

-L, --libs            Comma separated list of libraries to enable
                      on LIBRARY_PATH, CMAKE_LIBRARY_PATH and LD_LIBRARY_PATH.
                      Example: stdenv.cc.cc,curl,zlib

-I, --include-libs    Comma separated list of libraries to enable
                      on C_INCLUDE_PATH and CMAKE_INCLUDE_PATH.
                      Example: curl,zlib

Python language support:

-p, --python-packages Comma separated list of Python packages to enable
                      on PYTHONPATH.
                      Example: python3Packages.numpy,python3Packages.pyproj


-v, --verbose         Run in verbose mode.
-h, --help            Print this help and exit.

command               Command to execute in shell.
EOF
  exit
}

app_shell_nix_dir=${APP_SHELL_NIX_DIR:-.}

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
    -n| --nixpkgs)
      nixpkgs="${2-}"
      shift
      ;;
    -a | --apps)
      apps="${2-}"
      shift
      ;;
    -p| --python-packages)
      python_packages="${2-}"
      shift
      ;;
    -l| --libs)
      libs="${2-}"
      shift
      ;;
    -L| --include-libs)
      include_libs="${2-}"
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
cmd="nix build --print-out-paths --no-link"

if [ -n "${verbose-}" ]; then
  cmd+=" --print-build-logs --show-trace"
fi

cmd+=" --file ${app_shell_nix_dir}/app-shell.nix"

if [ -n "${nixpkgs-}" ]; then
  cmd+=" --argstr nixpkgs $nixpkgs"
fi

if [ -n "${apps-}" ]; then
  cmd+=" --argstr apps $apps"
fi

if [ -n "${python_packages-}" ]; then
  cmd+=" --argstr pythonPackages $python_packages"
fi

if [ -n "${libs-}" ]; then
  cmd+=" --argstr libs $libs"
fi

if [ -n "${include_libs-}" ]; then
  cmd+=" --argstr includeLibs $include_libs"
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
