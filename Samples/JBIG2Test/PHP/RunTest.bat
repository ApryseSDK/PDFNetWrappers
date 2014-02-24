@echo off
setlocal
set TEST_NAME=JBIG2Test
set PATH=..\..\..\PDFNetC\Lib;%PATH%
php.exe %TEST_NAME%.php
endlocal
