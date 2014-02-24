@echo off
setlocal
set TEST_NAME=PDFRedactTest
set PATH=..\..\..\PDFNetC\Lib;%PATH%
php.exe %TEST_NAME%.php
endlocal
