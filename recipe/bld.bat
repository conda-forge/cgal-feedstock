REM this test requires numpy and we do not want to build-depend on it
del examples\python\test_aabb2.py

REM https://github.com/CGAL/cgal-swig-bindings/issues/77
del examples\python\test_polyline_simplification_2.py

mkdir build && cd build

set CMAKE_CONFIG=Release

cmake -LAH -G"Ninja" ^
  -DCMAKE_BUILD_TYPE=%CMAKE_CONFIG% ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DPYTHON_MODULE_PATH="%SP_DIR%" ^
  -DBUILD_JAVA=OFF ^
  .. || exit /B 1

ninja install || exit /B 1
ctest --output-on-failure
