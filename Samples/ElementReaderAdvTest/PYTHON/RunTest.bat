@echo off
setlocal
call ..\..\py_init.bat
set TEST_NAME=ElementReaderAdvTest
python.exe -u %TEST_NAME%.py
endlocal
