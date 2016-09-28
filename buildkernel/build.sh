#!/bin/bash

VERSION=$1

if [[ -z "${VERSION}" ]]; then
	echo "Syntax: $0 <version>"
	echo "  where version is an official kernel version, e.g. 4.4.20"
        exit 1
fi

set -ex

mkdir -p dist/${VERSION}

docker build -f src/images/builder/Dockerfile -t kernelbuilder src

docker run --rm -v `pwd`/dist/${VERSION}:/dist kernelbuilder /src/build-in-docker.sh ${VERSION}

