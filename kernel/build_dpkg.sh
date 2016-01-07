#!/bin/sh

cp config-3.16-titan linux-stable/.config || exit 1

cd linux-stable || exit 1

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- oldconfig || exit 1

export KBUILD_PKG_ROOTCMD='fakeroot -u'

# TODO: use git describe to create KDEB_PKGVERSION
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- LOCALVERSION=-titan2 KDEB_PKGVERSION=$(make kernelversion)-1 V=1 deb-pkg

