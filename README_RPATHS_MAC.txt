If you get an error message of the following sort on a Mac that has System Integrity Protection enabled:

	dyld: warning, LC_RPATH . in /Users/Username/PDFNetWrappersMac/PDFNetC/Lib/PDFNetRuby.bundle being ignored in restricted program because it is a relative path
-- OR --
	dyld: warning, LC_RPATH . in /Users/Username/PDFNetWrappersMac/PDFNetC/Lib/_PDFNetPython.so being ignored in restricted program because it is a relative path
	
Run the script named "fix_rpaths.sh". 