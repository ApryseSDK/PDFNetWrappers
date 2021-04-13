@echo off
setlocal
set TEST_NAME=PDF2WordTest
SET PATH=..\..\..\PDFNetC\Lib;%PATH%
ruby.exe %TEST_NAME%.rb
endlocal
