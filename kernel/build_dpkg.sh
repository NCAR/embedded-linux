#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: ${0##*/} config_file"
    exit 1
fi

config=$1

# version number of this repository
debver=$(git describe --match '[vV][0-9]*' 2>/dev/null || echo v1.0-0)
debver=${debver/#v/}    # remove leading v
debver=${debver//-/+}   # replace dashes with .

cp $config linux-stable-armel/.config || exit 1

cd linux-stable-armel || exit 1

# make ARCH=arm distclean || exit 1

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- oldconfig || exit 1

export KBUILD_PKG_ROOTCMD='fakeroot -u'

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- KDEB_PKGVERSION=$debver V=1 deb-pkg || exit 1

