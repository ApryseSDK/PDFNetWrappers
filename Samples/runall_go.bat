LICENSE_KEY=""

if exist go.mod (
    go mod init pdftron-test
    go mod edit -replace github.com/pdftron/pdftron-go=../
    go mod tidy
)

go test ./... -license=%LICENSE_KEY%
