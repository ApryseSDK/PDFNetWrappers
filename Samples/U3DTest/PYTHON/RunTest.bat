@echo off
setlocal
call ..\..\py_init.bat
set TEST_NAME=U3DTest
python.exe -u %TEST_NAME%.py
endlocal
