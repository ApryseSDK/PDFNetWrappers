@echo off
setlocal
call ..\..\py_init.bat
set TEST_NAME=TextSearchTest
python.exe -u %TEST_NAME%.py
endlocal
