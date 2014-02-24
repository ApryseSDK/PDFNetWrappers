@echo off
for /D %%s in (*) do (
    if exist %%s\PYTHON\RunTest.bat (
        cd %%s\PYTHON
        echo %%s starting...
        call RunTest.bat
        cd ..\..
        echo %%s finished.
        pause
    )
)

echo Run all tests finished.
