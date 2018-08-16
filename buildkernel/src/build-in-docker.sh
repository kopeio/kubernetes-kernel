#!/bin/bash

VERSION=$1

if [[ -z "${VERSION}" ]]; then
        echo "Syntax: $0 <version>"
        echo "  where version is an official kernel version, e.g. 4.4.39"
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

# Apply patch
if [[ -f /src/patch-${VERSION} ]]; then
  patch -p1 < /src/patch-${VERSION}
fi

# Verify we have requirements early
make -C tools/perf/Documentation/ check-man-tools


#make-kpkg clean
#fakeroot make-kpkg -j 64 --initrd --append-to-version -k8s --revision=${REVISION} buildpackage


make clean
#make -j64 deb-pkg LOCALVERSION=-k8s KDEB_PKGVERSION=${KDEB_PKGVERSION} KDEB_SOURCENAME=${KDEB_SOURCENAME} KERNELRELEASE=${KERNELRELEASE}
make -j64 deb-pkg LOCALVERSION=-k8s KDEB_PKGVERSION=${KDEB_PKGVERSION}

cp /build/*.deb /dist/
cp /build/*.dsc /dist/
cp /build/*.tar.gz /dist/



#####################################################################
# We now build the perf package


make -C tools/perf/ install DESTDIR=/tmp/perf-package/linux-perf-4.4/usr


cd /tmp/perf-package/
mkdir -p linux-perf-4.4/DEBIAN

cat << EOF > linux-perf-4.4/DEBIAN/control
Package: linux-perf-4.4
Source: linux
Version: ${VERSION}
Architecture: amd64
Maintainer: Kopeio Kernel Team <kernel@kopeio.org>
Depends: libaudit1 (>= 1:2.2.1), libc6 (>= 2.14), libc6-i386 (>= 2.7), libc6-x32 (>= 2.16), libdw1 (>= 0.157), libelf1 (>= 0.144), libnuma1, libperl5.20 (>= 5.20.2), libpython2.7 (>= 2.7), libslang2 (>= 2.2.4), libunwind8, zlib1g (>= 1:1.1.4)
Recommends: linux-base
Suggests: linux-doc-4.4
Conflicts: linux-tools-4.4
Replaces: linux-tools-4.4
Provides: linux-tools-4.4
Section: devel
Priority: optional
Homepage: https://www.kernel.org/
Description: Performance analysis tools for Linux 4.4
 This package contains the 'perf' performance analysis tools for Linux
 kernel version 4.4.
 .
 The linux-base package contains a 'perf' command which will invoke the
 appropriate version for the running kernel.
EOF

cat << EOF > linux-perf-4.4/DEBIAN/conffiles
EOF

cd  linux-perf-4.4/
mkdir -p usr/lib
mv usr/bin/perf usr/bin/perf_4.4
# TODO: rename usr/libexec to usr/lib ?
mv usr/libexec/perf-core usr/lib/perf_4.4-core
# TODO: rename usr/lib64 to usr/lib ?
mv usr/lib64/traceevent usr/lib/traceevent_4.4
mkdir -p usr/share/bash-completion/completions/
mv ./usr/etc/bash_completion.d/perf usr/share/bash-completion/completions/perf_4.4
# TODO: missing?
#mkdir -p usr/share/doc
#mv usr/share/doc/linux-perf usr/share/doc/linux-perf-4.4
# TODO: missing?
#mv usr/share/lintian/overrides/linux-perf usr/share/lintian/overrides/linux-perf-4.4
find usr/share/man -type f | xargs rename  's/perf/perf_4.4/'
find usr/share/man -type f | xargs gzip
mv usr/share/perf-core usr/share/perf_4.4-core
# TODO: keep?
rm -f ./usr/lib64/libperf-gtk.so
rm -rf ./usr/lib64/
rm -rf ./usr/libexec/
cd ..

fakeroot dpkg-deb --build linux-perf-4.4/
cp *.deb /dist/
