#!/bin/sh
TEST_NAME=OfficeToPDFTest
export LD_LIBRARY_PATH=../../../PDFNetC/Lib
. ../../py_init.sh
$python_exe -u $TEST_NAME.py