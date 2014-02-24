@echo off
setlocal
set TEST_NAME=TextExtractTest
SET PATH=..\..\..\PDFNetC\Lib;%PATH%
ruby.exe %TEST_NAME%.rb
endlocal
