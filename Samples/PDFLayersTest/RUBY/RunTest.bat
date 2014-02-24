@echo off
setlocal
set TEST_NAME=PDFLayersTest
SET PATH=..\..\..\PDFNetC\Lib;%PATH%
ruby.exe %TEST_NAME%.rb
endlocal
