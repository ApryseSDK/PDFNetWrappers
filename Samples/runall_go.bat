SET PATH=%cd%/../shared_libs/win/Lib/;%PATH%

set LICENSE_KEY=""
set MODULE_PATH=""

if NOT exist go.mod (
    go mod init pdftron-test
    go mod edit -replace github.com/pdftron/pdftron-go=%cd%/../
    go mod tidy
)

go test -v ./... -license=%LICENSE_KEY% -modulePath=%MODULE_PATH%
