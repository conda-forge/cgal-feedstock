#!/bin/sh

# this test requires numpy and we do not want to build-depend on it
rm examples/python/test_aabb2.py

# https://github.com/CGAL/cgal-swig-bindings/issues/77
rm examples/python/test_polyline_simplification_2.py

mkdir build && cd build

export CMAKE_CONFIG=Release

cmake -LAH -G"${CMAKE_GENERATOR}" \
  -DCMAKE_BUILD_TYPE=${CMAKE_CONFIG} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DBUILD_JAVA=OFF \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  ..

make VERBOSE=1 install -j${CPU_COUNT}

DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib ctest --output-on-failure -j${CPU_COUNT}
