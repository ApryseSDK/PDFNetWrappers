#!/bin/sh
LICENSE_KEY=""

#absolute path
MODULE_PATH=""

if [ ! -f "go.mod" ]; then
	go mod init pdftron-test
	go mod edit -replace github.com/pdftron/pdftron-go=../
	go mod tidy
fi

go test ./... -v -license=$LICENSE_KEY -modulePath=$MODULE_PATH
