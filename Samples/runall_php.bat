@echo off
for /D %%s in (*) do (
    if exist %%s\PHP\RunTest.bat (
        cd %%s\PHP
        echo %%s starting...
        call RunTest.bat
        cd ..\..
        echo %%s finished.
        pause
    )
)

echo Run all tests finished.
