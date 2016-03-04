#!/bin/bash

if ! [ -f /etc/debian_version ]; then
    echo "Run this on debian systems"
    exit 1
fi

# Build Debian kernel packages for armel systems.

# The plan is to have version 1 and 2 kernels on the DSMs.
#   /boot/vmlinuz-3.16.0-titan1
#   /boot/vmlinuz-3.16.0-titan2

# RedBoot on the DSMs will be configured to run the version 2 kernels,
# and new kernels that are build should be version 2 kernels, and the
# version 1's are a fallback in case a version 2 won't boot.

# So usually:
# CONFIG_LOCALVERSION=viper2 or CONFIG_LOCALVERSION=titan2.

# Info on the interplay of CONFIG_LOCALVERSION,
#   CONFIG_LOCALVERSION_AUTO and the LOCALVERSION make argument

# make option LOCALVERSION not specified
# CONFIG_LOCALVERSION_AUTO=y
#   linux-image-3.16.0-titan2-00001-g1a10d22_1.0+0_armel.deb
#   The linux-headers package then places headers in
#   /usr/src/linux-headers-3.16.0-titan2-00001-g1a10d22/
#   Seems too hard to keep track of.

# make option LOCALVERSION not specified
# CONFIG_LOCALVERSION_AUTO is not set
# repo dirty, results in "+" sign
#   linux-image-3.16.0-titan2+_1.0+0_armel.deb

# repo dirty, make LOCALVERSION="test"
#   linux-image-3.16.0-titan2test_1.0+0_armel.deb

# make option blank: make LOCALVERSION=
# CONFIG_LOCALVERSION_AUTO is not set
#   linux-image-3.16.0-titan2_1.0+0_armel.deb
# We'll go with this settings.

set -e

usage() {
    echo "Usage: ${1##*/} [-c] [-s] [-i repository ] [-v N] config_file"
    echo "-n: don't do a distclean before build"
    echo "-i: install them with reprepro to the repository"
    echo "-s: sign the package files with $key"
    echo "-v N: verbosity, default=0"
    exit 1
}

key='<eol-prog@eol.ucar.edu>'
debarch=armel
verbosity=0
distclean=true
sign=false
while [ $# -gt 0 ]; do
    case $1 in
    -s)
        sign=true
        ;;
    -i)
        shift
        repo=$1
        ;;
    -h)
        usage $0
        ;;
    -n)
        distclean=false
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

[ $config ] || usage $0

localv=

# version number of this repository
debver=$(git describe --match '[vV][0-9]*' 2>/dev/null || echo v1.0-0)
debver=${debver/#v/}    # remove leading v
debver=${debver%-g*}    # remove trailing -gXXXXX
# debver=${debver//-/+}   # replace dashes with .

cd linux-stable-armel

# version number of linux-stable-armel
kdebver=$(git describe --match '[vV][0-9]*' 2>/dev/null)
kdebver=${kdebver/#v/}    # remove leading v
kdebver=${kdebver%-g*}    # remove trailing -gXXXXX
kdebcom=${kdebver##*-}    # get number of commits

kver=$(make kernelversion)  # 3.16.0
krel=$(make ARCH=arm kernelrelease)  # 3.16.0-titanN+

rm -f ../linux-firmware-image-${kver}-*_${debarch}.deb \
    ../linux-headers-${kver}-*_${debarch}.deb \
    ../linux-image-${kver}-*_${debarch}.deb \
    ../linux-libc-dev_*_${debarch}.deb

$distclean && make ARCH=arm distclean

cp ../$config .config

make ARCH=arm oldconfig

export KBUILD_PKG_ROOTCMD='fakeroot -u'

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- \
    LOCALVERSION=$localv KDEB_PKGVERSION=$debver.$kdebcom V=$verbosity deb-pkg
cd ..

pkgs=$(echo linux-firmware-image-${kver}-*_${debarch}.deb \
    linux-headers-${kver}-*_${debarch}.deb \
    linux-image-${kver}-*_${debarch}.deb)

if $sign; then
    export GPG_AGENT_INFO
    if [ -e $HOME/.gpg-agent-info ]; then
        . $HOME/.gpg-agent-info
    else
        echo "Warning: $HOME/.gpg-agent-info not found"
    fi
    for pkg in $pkgs; do
        dpkg-sig -k "$key" --gpg-options "--batch --no-tty" --sign builder $pkg
    done
fi

# remove _debver_armel.deb from names of packages passed to reprepro
pkgnames=
for pkg in $pkgs; do
    pkg=${pkg%_*}
    pkg=${pkg%_*}
    pkgnames="$pkgnames $pkg"
done

if [ -n "$repo" ]; then
    umask 0002
    set -e
    flock $repo sh -c "
        reprepro -V -b $repo remove jessie $pkgnames;
        reprepro -V -b $repo deleteunreferenced;
        reprepro -V -b $repo includedeb jessie $pkgs"

    rm -f $pkgs linux-libc-dev_*_${debarch}.deb

else
    echo "packages: $pkgs"
fi

