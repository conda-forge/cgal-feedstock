
mkdir build && cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles"                ^
  -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%"         ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"      ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"   ^
  -DWITH_CGAL_ImageIO=OFF -DWITH_CGAL_Qt5=OFF ^
  ..
if errorlevel 1 exit 1
cmake --build . --config %CMAKE_CONFIG% --target INSTALL
if errorlevel 1 exit 1

cd ..\..

:: language bindings are in a separate repo without releases
git clone https://github.com/CGAL/cgal-swig-bindings.git csb
cd csb
git checkout 59e2452

:: this test requires numpy and we do not want to build-depend on it
del examples\python\test_aabb2.py

:: https://github.com/CGAL/cgal-swig-bindings/issues/77
del examples\python\test_polyline_simplification_2.py

mkdir bld && cd bld

cmake -LAH -G"NMake Makefiles"                ^
  -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%"         ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"      ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"   ^
  -DPYTHON_MODULE_PATH="%SP_DIR%"             ^
  -DBUILD_JAVA=OFF                            ^
  ..
if errorlevel 1 exit 1
cmake --build . --config %CMAKE_CONFIG% --target INSTALL
if errorlevel 1 exit 1
ctest --output-on-failure
if errorlevel 1 exit 1
