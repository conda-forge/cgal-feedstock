#!/bin/sh

set -xe

mkdir build && cd build

cmake ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DBUILD_JAVA=OFF \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DPython_EXECUTABLE=$PREFIX/bin/python \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  ..

cmake --build . --config Release
cmake --build . --config Release --target install

# This fails when cross-compiling, even if emulation is available
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
    DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib ctest --output-on-failure -j${CPU_COUNT}
fi
