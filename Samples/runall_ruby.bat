@echo off
for /D %%s in (*) do (
    if exist %%s\RUBY\RunTest.bat (
        cd %%s\RUBY
        echo %%s starting...
        call RunTest.bat
        cd ..\..
        echo %%s finished.
        pause
    )
)

echo Run all tests finished.
