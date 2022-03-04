#!/bin/sh

# https://github.com/CGAL/cgal-swig-bindings/issues/77
rm examples/python/test_polyline_simplification_2.py

mkdir build && cd build

cmake ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DBUILD_JAVA=OFF \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DPython_EXECUTABLE=$PREFIX/bin/python \
  ..

cmake --build . --config Release
cmake --build . --config Release --target install

DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib ctest --output-on-failure -j${CPU_COUNT}
