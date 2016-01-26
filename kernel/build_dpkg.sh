#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: ${0##*/} [-c] [-v N] config_file"
    echo "-c: do distclean before build"
    echo "-v N: verbosity, default=0"
    exit 1
fi

verbosity=0
distclean=false
while [ $# -gt 0 ]; do
    case $1 in
    -c)
        distclean=true
        ;;
    -v)
        shift
        verbosity=$1
        ;;
    *)
        config=$1
        ;;
    esac
    shift
done

# With CONFIG_LOCALVERSION=titan2

# No make LOCALVERSION option specified
# CONFIG_LOCALVERSION_AUTO=y
#   linux-image-3.16.0-titan2-00001-g1a10d22_1.0+0_armel.deb
#   The linux-headers package then places headers in
#   /usr/src/linux-headers-3.16.0-titan2-00001-g1a10d22/
#   which is too hard to keep track of.

# CONFIG_LOCALVERSION_AUTO is not set
# No make LOCALVERSION option specified
# repo dirty, results in "+" sign
#   linux-image-3.16.0-titan2+_1.0+0_armel.deb
# repo dirty, make LOCALVERSION="test"
#   linux-image-3.16.0-titan2test_1.0+0_armel.deb
# make LOCALVERSION=
# CONFIG_LOCALVERSION_AUTO is not set
#   linux-image-3.16.0-titan2_1.0+0_armel.deb

# version number of this repository
debver=$(git describe --match '[vV][0-9]*' 2>/dev/null || echo v1.0-0)
debver=${debver/#v/}    # remove leading v
debver=${debver//-/+}   # replace dashes with .


cd linux-stable-armel || exit 1

$distclean && ( make ARCH=arm distclean || exit 1 )

lv=

cp ../$config .config || exit 1

make ARCH=arm oldconfig || exit 1

export KBUILD_PKG_ROOTCMD='fakeroot -u'

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- LOCALVERSION=$lv KDEB_PKGVERSION=$debver V=$verbosity deb-pkg || exit 1

