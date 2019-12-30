echo "Generating mocks for project using following environment: "
go env
go env GOROOT
export GO111MODULE=on
export PATH=$(go env GOROOT)/bin:$PATH
go get github.com/golang/mock/mockgen

ls $(go env GOPATH)/bin
go generate ./...

