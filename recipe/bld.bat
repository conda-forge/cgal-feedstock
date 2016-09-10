
mkdir build
cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles"                ^
  -DCMAKE_PREFIX_PATH="%PREFIX%"              ^
  -DCMAKE_INSTALL_PREFIX="%PREFIX%"           ^
  -DWITH_CGAL_ImageIO=OFF -DWITH_CGAL_Qt5=OFF ^
  ..
if errorlevel 1 exit 1
cmake --build . --config %CMAKE_CONFIG%
if errorlevel 1 exit 1
cmake --build . --config %CMAKE_CONFIG% --target INSTALL
if errorlevel 1 exit 1
