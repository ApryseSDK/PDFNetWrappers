#!/bin/sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $SCIRPT_DIR
cd "$SCRIPT_DIR" || exit 1

LICENSE_KEY="$ENV_LICENSE_KEY"
MODULE_PATH="$ENV_MODULE_PATH"

if [ ! -f "go.mod" ]; then
	go mod init pdftron-test
	go mod edit -replace github.com/pdftron/pdftron-go/v2=../
	go mod edit -require github.com/pdftron/pdftron-go/v2@v2.0.0
	go mod edit -require golang.org/x/text@v0.13.0
	go mod tidy
fi

if [ ! $# -eq 0 ]
  then
	  go test ./$1 -v -license="$LICENSE_KEY" -modulePath="$MODULE_PATH"
fi

go test ./... -v -license="$LICENSE_KEY" -modulePath="$MODULE_PATH"
