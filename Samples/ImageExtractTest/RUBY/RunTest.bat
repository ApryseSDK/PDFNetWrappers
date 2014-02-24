@echo off
setlocal
set TEST_NAME=ImageExtractTest
SET PATH=..\..\..\PDFNetC\Lib;%PATH%
ruby.exe %TEST_NAME%.rb
endlocal
