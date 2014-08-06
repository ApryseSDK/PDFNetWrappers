--------------------------------------------------------------------------------
About:
--------------------------------------------------------------------------------
This project demonstrates how to bind PDFNetC with other languages. This project provides the necessary files to generate language bindings between PDFNetC and the following:

    - PHP
    - Python
    - Ruby

--------------------------------------------------------------------------------
Requirements:
--------------------------------------------------------------------------------
This project uses SWIG (http://www.swig.org/) in order to generate the language binding source files. Furthermore, a C++ build enviroment is necessary for compiling and producing the bridge file. We have tested this project on the following environments:

    - Linux: GCC 4.6 and above
    - Windows: Visual Studio 2012 and above
    - Mac OS: XCode 5.0 and above

In order to generate project files, CMake version 2.8 or above is required.

Lastly, you will need to obtain the most recent package for PDFNetC. The package can be downloaded from here: http://www.pdftron.com/pdfnet/downloads.html. Make sure you download the one for PDFNetC (not for .NET). You will also need to make sure that the architure of PDFNetC you download matches the architecture of your interpreter. For example, if you have 64-bit Ruby interpreter, you will need to obtain the 64-bit version of PDFNetC.

--------------------------------------------------------------------------------
Building:
--------------------------------------------------------------------------------
The following steps describe how to build a language binding for PDFNetC using this source package. This guide assumes you are familiar with CMake project generation. For more information, please visit http://www.cmake.org/

1. Unpack PDFNetC to the PDFNetC folder. Make sure that both Headers/ and Lib/ folders exists inside the PDFNetC folder of this project.

2. Create an out-of-source build tree directory (i.e. Build)
    > mkdir Build

3. Go into the build directory and invoke CMake. At this step you can include other CMake options. (Alternatively, you may be able to use ccmake or cmake-gui which can show you which options you can set and change to modify the project file generation.)

  a. Python
    > cd Build
    > cmake -D BUILD_PDFNetPython=ON ..

  b. Ruby
    > cd Build
    > cmake -D BUILD_PDFNetRuby=ON ..

  c. PHP
    > cd Build
    > cmake -D BUILD_PDFNetPHP=ON ..

4. Run make or the IDE's build command
    > make

NOTE: To rebuild the bindings, you may need to delete the files in Build and re-run cmake.  This is because the CMake script itself compiles the SWIG bindings.

--------------------------------------------------------------------------------
Running the samples:
--------------------------------------------------------------------------------
1. In order to run the samples, you will need to run the install command first (or build the install projects from within the IDEs).
    > make install
    
* This should place the bridge files to the PDFNetC/Lib folder (where the PDFNetC library was extracted from the previous section).

2. Navigate to the Samples/ folder and either run the runall scripts, or go into the individual samples folder and run the runtest scripts.

--------------------------------------------------------------------------------
Example:
--------------------------------------------------------------------------------

Suppose you wanted to build and run the 64-bit PHP wrappers.  You could run the following set of commands:

> mkdir wrappers_build # Make a directory to build the wrappers in.
> cd wrappers_build # Move to that directory.
> git clone https://github.com/PDFTron/PDFNetWrappers # Git the code.
> cd PDFNetWrappers/PDFNetC # Move to where we download PDFNet.
> wget http://www.pdftron.com/downloads/PDFNetC64.tar.gz # Download PDFNet.
> tar xzvf PDFNetC64.tar.gz # Unpack PDFNet.
> mv PDFNetC64/Headers/ . # Move PDFNet Headers/ into place.
> mv PDFNetC64/Lib/ . # Move PDFNet Lib/ into place.
> cd .. # Go back up.
> mkdir Build # Create a directory to create the Makefiles in.
> cd Build # Move to that directory.
> cmake -D BUILD_PDFNetPHP=ON .. # Create the Makefiles with CMake.
> make # Build the PHP wrappers with SWIG.
> make install # Copy the PHP wrappers to where the samples can find them.
> cd ../Samples # Move to the Samples directory.
> ./runall_php.sh # Run all PHP code samples, using the new wrappers.

--------------------------------------------------------------------------------
Pre-built Binaries:
--------------------------------------------------------------------------------
You can download pre-built binaries from the following links:

Windows: Python 2.7.x
http://www.pdftron.com/downloads/PDFNetWrappers/PDFNetWrappersWin32.zip
http://www.pdftron.com/downloads/PDFNetWrappers/PDFNetWrappersWin64.zip

Linux: Python 2.7.x and Ruby 2.0.0
http://www.pdftron.com/downloads/PDFNetWrappers/PDFNetWrappersLinux.tar.gz
http://www.pdftron.com/downloads/PDFNetWrappers/PDFNetWrappersLinux64.tar.gz

Mac OS: Python 2.7.x and Ruby 2.0.0
http://www.pdftron.com/downloads/PDFNetWrappers/PDFNetWrappersMac.zip

--------------------------------------------------------------------------------
Common Questions:
--------------------------------------------------------------------------------
* Which versions of the interpreters are supported by this project?

Technically, any versions can be supported provided that some minor changes to the SWIG interface file must be made.
Within PDFTron, we have successfully built language bindings for the following versions of the interpreter:
    
    - PHP 5.3.x to 5.5.x
    - Python 2.7.x to 3.3.x
    - Ruby 1.8.5 to 2.0.0

* Does this project support UCS4 builds of Python?

Yes. It is important to keep in mind however, that you use the include directories and the configuration header file of this Python build.

* I cannot build PHP bindings for MAC OS

In order to build PHP bindings for MAC OS, we suggest building PHP yourself. When you try to use the bundled PHP interpreter with Mac OS, the CMake code generation process may not be able to locate the PHP header files as well as the PHP library file.

* Running the samples seems fine, but when I try to use it on my project, I am starting to get issues.

Make sure that your interpreter can find the PDFNetC library. The following information indicates where the PDFNetC library must be placed so that interpreters can find and load them:

    - Linux or Mac OS: Copy PDFNetC library (libPDFNetC.so or libPDFNetC.dylib) to any of the lib directories (i.e /usr/lib, /usr/local/lib, etc.)

    - Windows: Copy PDFNetC library (PDFNetC.dll) to %WINDIR%\System32 (or %WINDIR%\SysWOW64).

* I am having issues with SWIG.

Please obtain the latest official builds of SWIG at: http://www.swig.org/.

* How can I change the install location?

In order change the install location, modify the top level CMakelists.txt. Remove the forced setting of the CMAKE_INSTALL_PREFIX variable.

