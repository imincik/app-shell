#!/usr/bin/env bash

set -Eeuo pipefail

export APP_SHELL_NIX_DIR=../../
../../app-shell.bash --apps gcc --include-libs zlib -- gcc test.c -o test && ./test | grep "Hello"
