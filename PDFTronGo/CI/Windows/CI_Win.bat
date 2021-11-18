@echo  off
set PATH=C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin;%PATH%
rem echo %PATH%
rem cd "C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin"

cd %HOMEPATH%
curl -L https://www.pdftron.com/downloads/PDFNetC64.zip -O PDFNetC64.zip
curl -L https://github.com/PDFTron/PDFNetWrappers/archive/master.zip -O master.zip
powershell.exe -NoP -NonI -Command "Expand-Archive '.\master.zip' '.\'"
ren PDFNetWrappers-Master PDFNetWrappers
powershell.exe -NoP -NonI -Command "Expand-Archive '.\PDFNetC64.zip' '.\PDFNetC64\'"
move PDFNetC64 PDFNetWrappers
cd PDFNetWrappers
xcopy PDFNetC64\PDFNetC64\Headers PDFNetC\Headers /E/H/C/I
xcopy PDFNetC64\PDFNetC64\Lib PDFNetC\Lib /E/H/C/I
mkdir Build
cd Build
cmake -G "MinGW Makefiles" -D BUILD_PDFTronGo=ON ..
cd PDFTronGo\pdftron\PDFNetC\Lib
rmdir /s /q net5.0
rmdir /s /q netcoreapp2.1
rmdir /s /q netstandard2.1
del libinfo.txt
del PDFNet.jar
cd ..
del README.txt
cd %HOMEPATH%
copy pdftron.go.replace PDFNetWrappers\Build\PDFTronGo\pdftron
copy pdftron_wrap.cxx.replace PDFNetWrappers\Build\PDFTronGo\pdftron
copy pdftron_wrap.h.replace PDFNetWrappers\Build\PDFTronGo\pdftron
copy replace.py PDFNetWrappers\Build\PDFTronGo\pdftron
cd PDFNetWrappers\Build\PDFTronGo\pdftron
python replace.py
g++ -shared -IPDFNetC/Headers -LPDFNetC/Lib -lPDFNetC pdftron_wrap.cxx -o pdftron.dll
move pdftron.dll PDFNetC\Lib
del pdftron.go.replace
del pdftron_wrap.cxx.replace
del pdftron_wrap.h.replace
del replace.py
del pdftron_wrap.cxx
del pdftron_wrap.h
rmdir /s /q PDFNetC\Headers