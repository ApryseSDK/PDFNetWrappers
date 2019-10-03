@echo off
setlocal
call ..\..\py_init.bat
set TEST_NAME=JBIG2Test
python.exe -u %TEST_NAME%.py
endlocal
