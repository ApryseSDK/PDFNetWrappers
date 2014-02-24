@echo off
setlocal
set TEST_NAME=HTML2PDFTest
SET PATH=..\..\..\PDFNetC\Lib;%PATH%
ruby.exe %TEST_NAME%.rb
endlocal
