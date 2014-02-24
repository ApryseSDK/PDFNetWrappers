@echo off
setlocal
set TEST_NAME=U3DTest
set PATH=..\..\..\PDFNetC\Lib;%PATH%
php.exe %TEST_NAME%.php
endlocal
