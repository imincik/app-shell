#!/usr/bin/env bash

set -Eeuo pipefail

echo -e "\nTest --app option ..."
./app-shell.bash --apps gdal,pdal -- gdalinfo --version | grep "GDAL"

echo -e "\nTest --python-packages option ..."
./app-shell.bash --apps python3 --python-packages python3Packages.numpy,python3Packages.pyproj -- 'python3 -c "import pyproj; print(pyproj)"' | grep "module 'pyproj'"

echo -e "\nTest --libs option ..."
./app-shell.bash --libs stdenv.cc.cc,libz -- env | grep LD_LIBRARY_PATH  | grep "gcc"

echo -e "\nDONE: SUCCESS"
