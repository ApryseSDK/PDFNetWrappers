@echo off
setlocal
set TEST_NAME=ImpositionTest
set PATH=..\..\..\PDFNetC\Lib;%PATH%
php.exe %TEST_NAME%.php
endlocal
