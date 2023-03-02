LICENSE_KEY=""
MODULE_PATH=""

if exist go.mod (
    go mod init pdftron-test
    go mod edit -replace github.com/pdftron/pdftron-go=../
    go mod tidy
)

go test ./... -v -license=%LICENSE_KEY% -modulePath=%MODULE_PATH%
