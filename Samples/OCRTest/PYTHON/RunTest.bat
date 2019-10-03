@echo off
setlocal
call ..\..\py_init.bat
set TEST_NAME=OCRTest
python.exe -u %TEST_NAME%.py
endlocal
