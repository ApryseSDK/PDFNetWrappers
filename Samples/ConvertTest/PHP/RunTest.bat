@echo off
setlocal
set TEST_NAME=ConvertTest
set PATH=..\..\..\PDFNetC\Lib;%PATH%
php.exe %TEST_NAME%.php
endlocal
