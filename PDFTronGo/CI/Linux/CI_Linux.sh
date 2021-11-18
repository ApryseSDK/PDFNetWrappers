#!/bin/sh

cd $HOME
mkdir wrappers_build # Make a directory to build the wrappers in.
cd wrappers_build # Move to that directory.
git clone https://github.com/PDFTron/PDFNetWrappers # Git the code.
cd PDFNetWrappers/PDFNetC # Move to where we download PDFNet.
wget http://www.pdftron.com/downloads/PDFNetC64.tar.gz # Download PDFNetC 9.1
tar xzvf PDFNetC64.tar.gz # Unpack PDFNet.
mv PDFNetC64/Headers/ . # Move PDFNet Headers/ into place.
mv PDFNetC64/Lib/ . # Move PDFNet Lib/ into place.
cd .. # Go back up.
mkdir Build # Create a directory to create the Makefiles in.
cd Build # Move to that directory.
cmake -D BUILD_PDFTronGo=ON .. # Create the pdftron directory.
cd PDFTronGo/pdftron
mv pdftron_wrap.cxx PDFNetC/Lib
mv pdftron_wrap.h PDFNetC/Lib
cd PDFNetC/Lib
g++ -fuse-ld=gold -fpic -I ../Headers -L . -lPDFNetC -Wl,-rpath,. -shared -static-libstdc++ pdftron_wrap.cxx -o libpdftron.so
mv PDFNetC64/Resources/ . # move the resources folder
rm PDFNetC64.tar.gz #cleanup starting
rm README.txt
rm -rd PDFNetC64/
rm -rd Headers/
cd Lib
rm -rd netcoreapp2.1
rm -rd netstandard2.1
rm -rd net5.0
rm libinfo.txt
rm PDFNet.jar
rm pdftron_wrap.h
rm pdftron_wrap.cxx
cd ../../Samples
rm py_init.bat
rm py_init.sh
rm runall_php.bat
rm runall_php.sh
rm runall_python.bat
rm runall_python.sh
rm runall_ruby.bat
rm runall_ruby.sh
cd $HOME
python3 cleanupandupdate_bat.py



