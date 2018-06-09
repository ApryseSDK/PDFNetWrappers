#! /bin/sh

if [ ! -f ./PDFNetC/Lib/libPDFNetC.dylib -o ! -f ./PDFNetC/Lib/_PDFNetPython.so ]; then
	echo ""
fi

install_name_tool -rpath . "$(pwd)/PDFNetC/Lib/" ./PDFNetC/Lib/_PDFNetPython.so
install_name_tool -delete_rpath . ./PDFNetC/Lib/libPDFNetC.dylib

install_name_tool -rpath . "$(pwd)/PDFNetC/Lib/" ./PDFNetC/Lib/PDFNetRuby.bundle

