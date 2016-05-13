#!/bin/bash

if ! [ -f /etc/debian_version ]; then
    echo "Run this on debian systems"
    exit 1
fi

set -e

usage() {
    echo "Usage: ${1##*/} [-n] [-v N] config_file"
    echo "-n: don't do a distclean before build"
    echo "-v N: verbosity, default=0"
    exit 1
}

debarch=armel
verbosity=0
distclean=true
while [ $# -gt 0 ]; do
    case $1 in
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

cd linux-stable-armel

$distclean && make ARCH=arm distclean

cp ../$config .config

make ARCH=arm oldconfig

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- \
    LOCALVERSION=$localv V=$verbosity zImage

