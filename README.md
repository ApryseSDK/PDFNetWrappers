# About

This project demonstrates how to bind PDFNetC with other languages. This project provides the necessary files to generate language bindings between PDFNetC and the following:

    PHP
    Python
    Ruby

# Requirements

This project uses SWIG (http://www.swig.org/) in order to generate the language binding source files. Furthermore, a C++ build environment is necessary for compiling and producing the bridge file. We have tested this project on the following:

## Environments and versions

* **SWIG** 2.0.4 - 2.0.12 and **SWIG** 3.0.12
* **CMake** version 2.8+
* **Linux**: GCC 4.6 and above
* **Windows**: Visual Studio 2012 and above
* **macOS**: XCode 5.0 and above

## Get PDFNetC

Lastly, you will need to obtain the most recent package for PDFNetC. The package can be downloaded from here: http://www.pdftron.com/pdfnet/downloads.html. Make sure you download the one for PDFNetC (not for .NET). You will also need to make sure that the architecture of PDFNetC you download matches the architecture of your interpreter. For example, if you have 64-bit Ruby interpreter, you will need to obtain the 64-bit version of PDFNetC.

## Strict PHP and SWIG version compatibility for PHP wrapper

Having a **single version of SWIG and PHP installed** on the server is preferred.  Any other combinations of SWIG and PHP versions not listed below is likely to encounter problems.  If your build is not working as expected then please double check the version numbers.  Installing multiple versions of SWIG and PHP may also produce issues.

* Targeting **PHP7**

    * **PHP7** with developer extensions and **SWIG3 (3.0.12)** or above

* Targeting **PHP5**

    * **PHP5** with developer extensions and **SWIG2 (2.0.4 - 2.0.12)**

## Strict PYTHON3 and SWIG3 version compatibility for PYTHON wrapper

Having a **single version of SWIG and PYTHON installed** on the server is preferred.  Any other combinations of SWIG and PYTHON versions not listed below is likely to encounter problems.  If your build is not working as expected then please double check the version numbers.  Installing multiple versions of SWIG and PYTHON may also produce issues.

* Targeting **PYTHON3**

    * **PYTHON3** with developer extensions and **SWIG3 (3.0.12)** or above

# Building

The following steps describe how to build a language binding for PDFNetC using this source package. This guide assumes you are familiar with CMake project generation. For more information, please visit http://www.cmake.org/

1. Unpack PDFNetC to the PDFNetC folder. Make sure that both Headers/ and Lib/ folders exists inside the PDFNetC folder of this project.

2. Create an out-of-source build tree directory (i.e. Build)
        `mkdir Build`

3. Go into the build directory and invoke CMake. At this step you can include other CMake options. (Alternatively, you may be able to use ccmake or cmake-gui which can show you which options you can set and change to modify the project file generation.)

  a. Python `cd Build cmake -D BUILD_PDFNetPython=ON ..`

  b. Ruby `cd Build cmake -D BUILD_PDFNetRuby=ON ..`

  c. PHP `cd Build cmake -D BUILD_PDFNetPHP=ON ..`

4. Run make or the IDE's build command
        `make`

NOTE: To rebuild the bindings, you may need to delete the files in Build and re-run cmake.  This is because the CMake script itself compiles the SWIG bindings.

# Running the samples

1. In order to run the samples, you will need to run the install command first (or build the install projects from within the IDEs).
        `make install`
    
* This should place the bridge files to the `PDFNetC/Lib` folder (where the PDFNetC library was extracted from the previous section).

2. Navigate to `Samples` folder and either run the `runall` scripts, or go into the individual samples folder and run the `RunTest` scripts.
3. Navigate to `Samples/TestFiles/Output` for outputs.
# Example 

## Linux 
Suppose you wanted to build and run the 64-bit `PHP` wrappers on `Linux`.  You could run the following set of commands:

    mkdir wrappers_build # Make a directory to build the wrappers in.
    cd wrappers_build # Move to that directory.
    git clone https://github.com/PDFTron/PDFNetWrappers # Git the code.
    cd PDFNetWrappers/PDFNetC # Move to where we download PDFNet.
    wget http://www.pdftron.com/downloads/PDFNetC64.tar.gz # Download PDFNet.
    tar xzvf PDFNetC64.tar.gz # Unpack PDFNet.
    mv PDFNetC64/Headers/ . # Move PDFNet Headers/ into place.
    mv PDFNetC64/Lib/ . # Move PDFNet Lib/ into place.
    cd .. # Go back up.
    mkdir Build # Create a directory to create the Makefiles in.
    cd Build # Move to that directory.
    sudo apt-get install php-dev # or sudo yum install php-devel, to add php-dev for required PHP include directories
    cmake -D BUILD_PDFNetPHP=ON .. # Create the Makefiles with CMake.
    make # Build the PHP wrappers with SWIG.
    sudo make install # Copy the PHP wrappers to where the samples can find them.
    cd ../Samples # Move to the Samples directory.
    ./runall_php.sh # Run all PHP code samples, using the new wrappers.

Please note that you may need to register PDFNetPHP.so as an extension to your PHP by adding the following line in your php.ini:

    extension=/full/path/to/PDFNetPHP.so

## macOS 
Suppose you wanted to build and run the `Ruby` wrappers on `macOS`.  You could run the following set of commands:

    mkdir wrappers_build # Make a directory to build the wrappers in.
    cd wrappers_build # Move to that directory.
    git clone https://github.com/PDFTron/PDFNetWrappers # Git the code.
    cd PDFNetWrappers/PDFNetC # Move to where we download PDFNet.
    curl -L -O http://www.pdftron.com/downloads/PDFNetCMac.zip # Download PDFNet.
    unzip PDFNetCMac.zip # Unpack PDFNet.
    mv PDFNetCMac/Headers/ . # Move PDFNet Headers/ into place.
    mv PDFNetCMac/Lib/ . # Move PDFNet Lib/ into place.
    cd .. # Go back up.
    mkdir Build # Create a directory to create the Makefiles in.
    cd Build # Move to that directory.
    cmake -D BUILD_PDFNetRuby=ON .. # Create the Makefiles with CMake.
    make # Build the Ruby wrappers with SWIG.
    sudo make install # Copy the Ruby wrappers to where the samples can find them.
    cp ../fix_rpaths.sh ../PDFNetC/Lib/  # fix rpath issue on Mac
    cd ../PDFNetC/Lib/
    sudo sh ./fix_rpaths.sh 
    cd ../../Samples # Move to the Samples directory.
    ./runall_ruby.sh # Run all Ruby code samples, using the new wrappers.
	
# Pre-built Binaries

You can download pre-built binaries from the following links:

## Windows: Python 2.7.x
http://www.pdftron.com/downloads/PDFNetWrappers/PDFNetWrappersWin32.zip

http://www.pdftron.com/downloads/PDFNetWrappers/PDFNetWrappersWin64.zip

## Linux: Python 2.7.x and Ruby 2.x
http://www.pdftron.com/downloads/PDFNetWrappers/PDFNetWrappersLinux.tar.gz

http://www.pdftron.com/downloads/PDFNetWrappers/PDFNetWrappersLinux64.tar.gz

## Mac OS: Python 2.7.x and Ruby 2.x
http://www.pdftron.com/downloads/PDFNetWrappers/PDFNetWrappersMac.zip

# Common Questions

## Which versions of the interpreters are supported by this project?

Technically, any versions can be supported provided that some minor changes to the SWIG interface file must be made.
Within PDFTron, we have successfully built language bindings for the following versions of the interpreter:
    
    - PHP 5.3.x to 5.5.x, PHP 7.x
    - Python 2.7.x to 3.3.x
    - Ruby 2.x

## Does this project support UCS4 builds of Python?

Yes. It is important to keep in mind however, that you use the include directories and the configuration header file of this Python build.

## I cannot build PHP bindings for macOS

In order to build `PHP` bindings for `macOS`, we suggest building PHP yourself. When you try to use the bundled PHP interpreter with macOS, the CMake code generation process may not be able to locate the PHP header files as well as the PHP library file. We recommend using `PHP7/SWIG3` to build PHP bindings for macOS.

## Running the samples seems fine, but when I try to use it on my project, I am starting to get issues.

Make sure that your interpreter can find the PDFNetC library. The following information indicates where the PDFNetC library must be placed so that interpreters can find and load them:

### Linux or macOS

    Copy PDFNetC library (libPDFNetC.so or libPDFNetC.dylib) to any of the lib directories (i.e /usr/lib, /usr/local/lib, etc.)

### Windows

    Copy PDFNetC library (PDFNetC.dll) to %WINDIR%\System32 (or %WINDIR%\SysWOW64).

## How can I change the install location?

In order to change the install location, modify the top level CMakelists.txt. Remove the forced setting of the `CMAKE_INSTALL_PREFIX` variable.

## How can I build wrappers for PDFNet 7.1.x and under?

The master branch supports PDFNet 8.0.x. In order to build wrappers using PDFNet 7.1.x and under, please use the following command to clone 7.1 branch instead (line 3 in `Example`): 

    git clone -b 7.1 --single-branch https://github.com/PDFTron/PDFNetWrappers # Git the code.

## I'm seeing a line-ending (control character) issue.

Example: `bad interpreter: /bin/sh^M: no such file or directory`

Using dos2unix to convert line endings can help with this issue

### Linux or macOS

```
brew install dos2unix
dos2unix **/*.sh
```
![](https://onepixel.pdftron.com/PDFNetWrappers)
