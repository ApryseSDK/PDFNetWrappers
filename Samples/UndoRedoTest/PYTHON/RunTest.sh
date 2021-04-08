#!/bin/sh
TEST_NAME=UndoRedoTest
python3 ../../init.py
rc=$?; if [ $rc != 0 ]; then exit $rc; fi
python3 -u $TEST_NAME.py
