
mkdir build && cd build

cmake -G "Ninja" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DPYTHON_MODULE_PATH="%SP_DIR%" ^
  -DPython_EXECUTABLE="%PYTHON%" ^
  -DBUILD_JAVA=OFF ^
  %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure
if errorlevel 1 exit 1
