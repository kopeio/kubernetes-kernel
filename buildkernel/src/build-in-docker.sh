#!/bin/bash

VERSION=$1

if [[ -z "${VERSION}" ]]; then
        echo "Syntax: $0 <version>"
        echo "  where version is an official kernel version, e.g. 4.4.26"
        exit 1
fi

set -ex

REVISION=`date +%Y%m%d`
#KDEB_SOURCENAME=linux-4.4
KDEB_PKGVERSION=${VERSION}-${REVISION}
#KERNELRELEASE=4.4

mkdir /build
cd /build

wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${VERSION}.tar.xz
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${VERSION}.tar.sign

# Trust Greg Kroah-Hartman key
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 38DBBDC86092693E

# Check signature
xz -cd linux-${VERSION}.tar.xz | gpg2 --verify linux-${VERSION}.tar.sign -

# TODO: How do we actually verify the signature here?

rm -rf linux-${VERSION}
tar xf linux-${VERSION}.tar.xz
cp /src/config-${VERSION} linux-${VERSION}/.config
cd linux-${VERSION}

#make-kpkg clean
#fakeroot make-kpkg -j 64 --initrd --append-to-version -k8s --revision=${REVISION} buildpackage


make clean
#make -j64 deb-pkg LOCALVERSION=-k8s KDEB_PKGVERSION=${KDEB_PKGVERSION} KDEB_SOURCENAME=${KDEB_SOURCENAME} KERNELRELEASE=${KERNELRELEASE}
make -j64 deb-pkg LOCALVERSION=-k8s KDEB_PKGVERSION=${KDEB_PKGVERSION}

cp /build/*.deb /dist/
cp /build/*.dsc /dist/
cp /build/*.tar.gz /dist/
