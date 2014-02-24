@echo off
setlocal
set TEST_NAME=JBIG2Test
SET PATH=..\..\..\PDFNetC\Lib;%PATH%
ruby.exe %TEST_NAME%.rb
endlocal
