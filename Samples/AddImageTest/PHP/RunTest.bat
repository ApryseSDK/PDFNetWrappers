@echo off
setlocal
set TEST_NAME=AddImageTest
set PATH=..\..\..\PDFNetC\Lib;%PATH%
php.exe %TEST_NAME%.php
endlocal
