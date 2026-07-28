#!/bin/sh

set -xe

mkdir build && cd build

# When cross-compiling, CMake's FindPython cannot run the target interpreter to
# discover its ABI. For free-threaded CPython (e.g. cp314t) it then falls back to
# the default GIL-enabled ABI, searches for the python3.X headers/libs and misses
# the python3.Xt ones that actually ship. FindPython fails with
#   Could NOT find Python (missing: Python_INCLUDE_DIRS Interpreter Development.Module)
# and the Python bindings are silently skipped, so the package ships without the
# importable `CGAL` module. Point FindPython at the real host include directory
# (python3.X or python3.Xt) so the ABI is detected and libpython is located.
PYTHON_INCLUDE_ARGS=""
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  PYTHON_INCLUDE_DIR=$(ls -d ${PREFIX}/include/python${PY_VER}*/ | head -n1)
  PYTHON_INCLUDE_ARGS="-DPython_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}"
fi

cmake ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DBUILD_JAVA=OFF \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DPython_EXECUTABLE=$PREFIX/bin/python \
  -DPython_ROOT_DIR=$PREFIX \
  ${PYTHON_INCLUDE_ARGS} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  ..

cmake --build . --config Release
cmake --build . --config Release --target install

# This fails when cross-compiling, even if emulation is available
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
    DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib ctest --output-on-failure -j${CPU_COUNT}
fi
