#!/bin/bash

VERSION=4.4.20

sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc

sudo apt-get --no-install-recommends install kernel-package

wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${VERSION}.tar.xz
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${VERSION}.tar.sign

# Trust Greg Kroah-Hartman key
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 38DBBDC86092693E

# Check signature
xz -cd linux-${VERSION}.tar.xz | gpg2 --verify linux-${VERSION}.tar.sign -

# TODO: How do we actually verify the signature here?

tar xf linux-${VERSION}.tar.xz

cp config-4.5.0-0.bpo.2-amd64 linux-${VERSION}/.config

cd linux-${VERSION}
make-kpkg clean

fakeroot make-kpkg -j 64 --initrd --revision=20160825.k8s buildpackage


