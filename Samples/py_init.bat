@echo off
set file_path=..\..\..\PDFNetC\Lib
set file=%file_path%\PDFNetPyLibInfo
set local_file=%file_path%\LocalPythonInfo

if not exist %file% (
	echo No PDFNetPyLibInfo was found!
	exit /b
)

set pdfnet_py_ver=2
findstr /b /c:"Python 3" %file% >nul
if %ERRORLEVEL% EQU 0 (
	set PYTHONIOENCODING=UTF-8
	set pdfnet_py_ver=3
)

set local_py_ver=0
python.exe --version > %local_file% 2>&1
findstr /b /c:"Python 3" %local_file% >nul
if %ERRORLEVEL% EQU 0 (
	set local_py_ver=3
)

findstr /b /c:"Python 2" %local_file% >nul
if %ERRORLEVEL% EQU 0 (
	set local_py_ver=2
)

set ERRORLEVEL=0
if %pdfnet_py_ver% NEQ %local_py_ver% (
	set ERRORLEVEL=2
	echo "ATTENTION:  PDFNetPython library (Python%pdfnet_py_ver%) and Python if installed (Python%local_py_ver%) in this local machine are not compatible! Please check your python version using command 'python.exe --version' from command prompt. Then you can download the correct package (Python2 or Python3) from our website."
	echo ""
	exit /b
)