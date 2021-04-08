@echo off
set TEST_NAME=U3DTest
python ..\..\init.py
if %errorlevel% neq 0 exit /b %errorlevel%
python -u %TEST_NAME%.py