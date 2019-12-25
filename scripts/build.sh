#!/usr/bin/shell

#checking if environment variables have been properly set
if [ -z "${ARCH}" ]
then
  echo "ARCH SHOULD BE SET"
  exit 1
fi
if [ -z "${OS}" ]
then
  echo "OS SHOULD BE SET"
  exit 1
fi

export CGO_ENABLED=0
export GOARCH="${ARCH}"
export GOOS="${OS}"
export GO111MODULE=on
export GOFLAGS="-mod=vendor"


echo "Building executable for project using following environment: "
go env
echo '========================================================='
set -x
#go install -installsuffix "static"                                   \
#   -ldflags "-X $(go list -m)/pkg/version.VERSION=${VERSION}"  \
#    ./...

#Building each handler to separate executable

  go install ./...



set +x
echo '===================COMPLETED============================='