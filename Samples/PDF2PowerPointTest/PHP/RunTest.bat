@echo off
setlocal
set TEST_NAME=PDF2PowerPointTest
set PATH=..\..\..\PDFNetC\Lib;%PATH%
php.exe %TEST_NAME%.php
endlocal
