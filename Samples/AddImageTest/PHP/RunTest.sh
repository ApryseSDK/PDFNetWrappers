#!/bin/sh
TEST_NAME=AddImageTest
export LD_LIBRARY_PATH=../../../PDFNetC/Lib
php -d extension="../../../PDFNetC/Lib/PDFNetPHP.so" $TEST_NAME.php
