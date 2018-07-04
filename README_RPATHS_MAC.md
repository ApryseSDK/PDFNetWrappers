# README FOR RPATH ISSUES ON MAC

On newer versions of the Mac OS X operating system, there is a feature called "System Integrity Protection" which forbids dynamic loading from relative paths. In order to address this and yet allow you to move our libraries to a different path on your filesystem, we have provided a script that changes the LC_RPATH entries inside our libraries to the path at which the libraries are located. The script only works once after you download fresh libraries, so you will have to download unchanged libraries and run the script on them again whenever you want to move them to a different directory.

## I am unable to run the samples

If you get one of these error messages, or similar: 

`dyld: warning, LC_RPATH . in /Users/Username/PDFNetWrappersMac/PDFNetC/Lib/PDFNetRuby.bundle being ignored in restricted program because it is a relative path`

`dyld: warning, LC_RPATH . in /Users/Username/PDFNetWrappersMac/PDFNetC/Lib/_PDFNetPython.so being ignored in restricted program because it is a relative path`

Then, the most likely problem is that your Mac OS X operating system has **System Integrity Protection** enabled, and the `LC_RPATH` of the PDFNet wrapper files need to be updated.

### Resolution
```
cd ./PDFNetC/Lib
./fix_rpaths.sh
```

## I am trying to integrate PDFNet into my project

If you get an error message similar to the ones above in your own project, the do the following **whenever you intend to move the library files to a different filesystem path:**

1. Download PDFNetC SDK again, or just extract again, so that you have *fresh* PDFNetC libraries.
2. Copy `fix_rpaths.sh` and the libraries you need (i.e. `libPDFNetC.dylib` and one or both of `_PDFNetPython.so`, `PDFNetRuby.bundle`) from `<package path>/PDFNetC/Lib` to the destination directory in your project.
3. Run `./fix_rpaths.sh` with the working directory set to the destination directory from step (2) above.
