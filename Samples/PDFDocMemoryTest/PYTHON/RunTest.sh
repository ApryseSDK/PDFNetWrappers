#!/bin/sh
TEST_NAME=PDFDocMemoryTest
export LD_LIBRARY_PATH=../../../PDFNetC/Lib
. ../../py_init.sh
$python_exe -u $TEST_NAME.py
