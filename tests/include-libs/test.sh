#!/usr/bin/env bash

set -Eeuo pipefail

export APP_SHELL_NIX_DIR=../../
../../app-shell.bash --apps gcc --libs curl --include-libs curl -- gcc test.c -lcurl -o test && ./test | grep "It works"
