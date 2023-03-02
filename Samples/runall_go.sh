#!/bin/sh

LICENSE_KEY="Aleksy:ENTERP:UnitTests::WLMIARP+:AMS(20250606):419FC5E03C09729B67B65B59BA386B05181FF61BC6046036BE02DAB6F5C7"


if [ ! -f "go.mod" ]; then
	go mod init pdftron-test
	go mod edit -replace github.com/pdftron/pdftron-go=../
	go mod tidy
fi

go test ./... -license=$LICENSE_KEY
