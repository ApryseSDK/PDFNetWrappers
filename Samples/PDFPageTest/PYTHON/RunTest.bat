@echo off
setlocal
call ..\..\py_init.bat
set TEST_NAME=PDFPageTest
python.exe -u %TEST_NAME%.py
endlocal
