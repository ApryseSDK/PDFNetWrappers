@echo off
SET PATH=%cd%/../shared_libs/win/Lib/;%PATH%
cd /D "%~dp0"

set LICENSE_KEY="%ENV_LICENSE_KEY%"
set MODULE_PATH="%ENV_MODULE_PATH%"

if NOT exist go.mod (
    go mod init pdftron-test
    go mod edit -replace github.com/pdftron/pdftron-go=../
    go mod edit -require github.com/pdftron/pdftron-go@v1.0.0
    go mod tidy
)

IF "%~1"=="" (
    go test -v ./... -license=%LICENSE_KEY% -modulePath=%MODULE_PATH%
) ELSE (go test -v ./%1 -license=%LICENSE_KEY% -modulePath=%MODULE_PATH%)
