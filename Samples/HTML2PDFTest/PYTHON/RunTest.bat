@echo off
setlocal
call ..\..\py_init.bat
set TEST_NAME=HTML2PDFTest
python.exe -u %TEST_NAME%.py
endlocal
