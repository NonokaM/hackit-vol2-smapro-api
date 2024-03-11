## tools install
.PHONY: tools-install
tools-install:
	go install golang.org/x/tools/cmd/goimports@v0.12.0
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.54.1

## fmt
.PHONY: fmt
fmt:
	goimports -w -local "go-college" cmd/
	gofmt -s -w cmd/

## lint
.PHONY: lint
lint:
	golangci-lint run -v cmd/... pkg/...

