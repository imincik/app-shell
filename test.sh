#!/usr/bin/env bash

set -Eeuo pipefail

./app-shell.bash --apps gdal,pdal -- gdalinfo --version | grep "GDAL"
./app-shell.bash --apps gdal,pdal,python3 --python-packages python3Packages.numpy,python3Packages.pyproj -- python3 --version | grep "Python"
./app-shell.bash --libs stdenv.cc.cc,libz -- env | grep LD_LIBRARY_PATH  | grep "gcc"

echo "DONE: SUCCESS"
