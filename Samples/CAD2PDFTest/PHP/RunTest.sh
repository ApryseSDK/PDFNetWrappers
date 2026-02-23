#!/bin/sh
TEST_NAME=CAD2PDFTest
export LD_LIBRARY_PATH=../../../PDFNetC/Lib
php -d extension="../../../PDFNetC/Lib/PDFNetPHP.so" $TEST_NAME.php
