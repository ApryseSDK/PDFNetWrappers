#! /bin/sh

if [ -f ./_PDFNetPython.so ]; then
	install_name_tool -rpath . "$(pwd)/" ./_PDFNetPython.so
fi

if [ -f ./PDFNetRuby.bundle ]; then
	install_name_tool -rpath . "$(pwd)/" ./PDFNetRuby.bundle
fi
