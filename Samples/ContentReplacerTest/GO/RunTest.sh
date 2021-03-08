#!/bin/sh
TEST_NAME=ContentReplacerTest
BIN_PATH="../../bin"

if [ ! -d $BIN_PATH ] 
then
    mkdir -p $BIN_PATH
fi

go build -o $BIN_PATH/$TEST_NAME.exe

if [ $? -eq 0 ] 
then
    $BIN_PATH/$TEST_NAME.exe
fi

