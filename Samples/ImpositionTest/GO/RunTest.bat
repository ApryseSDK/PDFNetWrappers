@echo off
if not exist ..\..\bin\ (
  md ..\..\bin\ >nul
)
if not exist ..\..\bin\PDFNetC.dll (
	copy ..\..\..\PDFNetC\Lib\PDFNetC.dll ..\..\bin\PDFNetC.dll >nul
)
setlocal
set TEST_NAME=ImpositionTest
go build -o ../../bin/%TEST_NAME%.exe
if %ERRORLEVEL% NEQ 0 goto EOF
call ..\..\bin\%TEST_NAME%.exe
:EOF
endlocal
