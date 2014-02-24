@echo off
setlocal
set TEST_NAME=TextExtractTest
set PATH=..\..\..\PDFNetC\Lib;%PATH%
php.exe %TEST_NAME%.php
endlocal
