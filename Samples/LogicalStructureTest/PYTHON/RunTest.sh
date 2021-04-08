#!/bin/sh
TEST_NAME=LogicalStructureTest
python3 ../../init.py
rc=$?; if [ $rc != 0 ]; then exit $rc; fi
python3 -u $TEST_NAME.py
