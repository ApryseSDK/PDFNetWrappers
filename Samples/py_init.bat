@echo off
set file_path=..\..\..\PDFNetC\Lib
set file=%file_path%\PDFNetPyLibInfo
if not exist %file% (
	echo No PDFNetPyLibInfo was found!
	exit /b
)

findstr /b /n "python3" %file% >nul
if errorlevel 0 (
	set PYTHONIOENCODING=UTF-8
)
