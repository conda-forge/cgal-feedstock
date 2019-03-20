#!/bin/sh

mkdir build && cd build

# needs qt5 for imageio
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCGAL_INSTALL_LIB_DIR=lib \
  -DWITH_CGAL_ImageIO=OFF \
  -DWITH_CGAL_Qt5=OFF \
  ..
make install -j${CPU_COUNT}

cd ../..

# language bindings are in a separate repo without releases
git clone https://github.com/CGAL/cgal-swig-bindings.git csb
cd csb
git checkout d708146e14c9ec70ea5af4c9c8934742089253f9

# this test requires numpy and we do not want to build-depend on it
rm examples/python/test_aabb2.py

# https://github.com/CGAL/cgal-swig-bindings/issues/77
rm examples/python/test_polyline_simplification_2.py

mkdir build && cd build

if [ `uname` == Darwin ]; then
  # Fixes link issues with python lib in macOS
  # See https://github.com/conda-forge/cgal-feedstock/pull/41
  # and https://blog.tim-smith.us/2015/09/python-extension-modules-os-x/
  export "LDFLAGS=-undefined dynamic_lookup $LDFLAGS"
fi

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DBUILD_JAVA=OFF \
  -DLINK_PYTHON_LIBRARY=OFF \
  ..
make install -j${CPU_COUNT}
DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib ctest --output-on-failure -j${CPU_COUNT}
