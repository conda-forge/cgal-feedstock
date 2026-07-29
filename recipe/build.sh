#!/bin/sh

set -xe

mkdir build && cd build

# Free-threaded CPython (e.g. cp314t) under cross-compilation.
#
# CMake's FindPython cannot run the target interpreter when cross-compiling, so
# it determines the ABI from Python_FIND_ABI, whose GIL element defaults to OFF
# (GIL-enabled). It then searches for the python3.X headers/library, misses the
# python3.Xt ones that actually ship, and fails with
#   Could NOT find Python (missing: Interpreter Development.Module)
# The Python bindings are silently skipped and the package ships without the
# importable `CGAL` module (`import CGAL` fails the test on linux-aarch64,
# linux-ppc64le and osx-arm64 cp314t). Native and GIL-enabled builds detect the
# ABI by running / name-matching the interpreter and are unaffected.
#
# When cross-compiling a free-threaded host python, enable the no-GIL ABI and
# hand FindPython the real host artifacts so it locates them.
PYTHON_CROSS_ARGS=""
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  PYTHON_INCLUDE_DIR=$(ls -d ${PREFIX}/include/python${PY_VER}*/ 2>/dev/null | head -n1)
  case "${PYTHON_INCLUDE_DIR%/}" in
    *t)
      # Python_FIND_ABI is a <debug>;<pymalloc>;<unicode>;<gil-disabled> list.
      # Its GIL element defaults to OFF and, since the target interpreter cannot
      # be run under cross-compilation, FindPython can neither confirm the no-GIL
      # ABI nor accept the interpreter (its abiflags are assumed "<none>"). Using
      # ANY for every element makes the accepted-abiflags set contain BOTH the
      # empty flag (so the un-runnable interpreter is accepted) and "t" (so the
      # free-threaded headers/library match), which resolves the Interpreter and
      # Development.Module components without executing anything.
      PYTHON_CROSS_ARGS="-DPython_FIND_ABI=ANY;ANY;ANY;ANY -DPython_INCLUDE_DIR=${PYTHON_INCLUDE_DIR%/}"
      PYTHON_LIBRARY=$(ls ${PREFIX}/lib/libpython${PY_VER}t*.so ${PREFIX}/lib/libpython${PY_VER}t*.dylib 2>/dev/null | head -n1)
      if [[ -n "${PYTHON_LIBRARY}" ]]; then
        PYTHON_CROSS_ARGS="${PYTHON_CROSS_ARGS} -DPython_LIBRARY=${PYTHON_LIBRARY}"
      fi
      ;;
  esac
fi

cmake ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DBUILD_JAVA=OFF \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DPython_EXECUTABLE=$PREFIX/bin/python \
  -DPython_ROOT_DIR=$PREFIX \
  ${PYTHON_CROSS_ARGS} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  ..

cmake --build . --config Release
cmake --build . --config Release --target install

# This fails when cross-compiling, even if emulation is available
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
    DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib ctest --output-on-failure -j${CPU_COUNT}
fi
