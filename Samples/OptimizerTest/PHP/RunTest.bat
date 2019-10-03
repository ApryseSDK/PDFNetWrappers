@echo off
setlocal
call ..\..\py_init.bat
set TEST_NAME=OptimizerTest
set PATH=..\..\..\PDFNetC\Lib;%PATH%
php.exe %TEST_NAME%.php
endlocal
