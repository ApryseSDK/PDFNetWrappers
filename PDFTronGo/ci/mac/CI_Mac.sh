#!/bin/sh

cd $HOME
mkdir wrappers_build # Make a directory to build the wrappers in.
cd wrappers_build # Move to that directory.
git clone https://github.com/PDFTron/PDFNetWrappers # Git the code.
cd PDFNetWrappers/PDFNetC # Move to where we download PDFNet.
wget http://www.pdftron.com/downloads/PDFNetCMac.zip # Download PDFNetC 9.1
tar xzvf PDFNetCMac.zip # Unpack PDFNet.
mv PDFNetCMac/Headers/ . # Move PDFNet Headers/ into place.
mv PDFNetCMac/Lib/ . # Move PDFNet Lib/ into place.
cd .. # Go back up.
mkdir Build # Create a directory to create the Makefiles in.
cd Build # Move to that directory.
cmake -D BUILD_PDFTronGo=ON .. # Create the pdftron directory.
cd PDFTronGo/pdftron
mv pdftron_wrap.cxx PDFNetC/Lib
mv pdftron_wrap.h PDFNetC/Lib
cd PDFNetC/Lib
gcc -fPIC -lstdc++ -I../Headers -L. -lPDFNetC -dynamiclib -undefined suppress -flat_namespace pdftron_wrap.cxx -o libpdftron.dylib
mv PDFNetCMac/Resources/ . # move the resources folder
rm PDFNetCMac.zip #cleanup starting
rm README.txt
rm -rd PDFNetCMac/
rm -rd Headers/
cd Lib
rm -rd netcoreapp2.1
rm -rd netstandard2.1
rm -rd net5.0
rm libinfo.txt
rm PDFNet.jar
rm pdftron_wrap.h
rm pdftron_wrap.cxx
