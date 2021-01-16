@echo off
setlocal
set TEST_NAME=CAD2PDFTest
SET PATH=..\..\..\PDFNetC\Lib;%PATH%
ruby.exe %TEST_NAME%.rb
endlocal
