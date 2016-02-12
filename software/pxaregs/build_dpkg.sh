#!/bin/sh

# git clone to $tmpdir
# copy debian directory to $tmpdir
# build "native" package

key="<eol-prog@eol.ucar.edu>"

usage() {
    echo "Usage: ${1##*/} [-s] [-i repository ] arch"
    echo "-s: sign the package files with key=$key"
    echo "-i: install them with reprepro to the repository"
    echo "arch is armel"
    exit 1
}

if [ $# -lt 1 ]; then
    usage $0
fi

sign=false
arch=armel
while [ $# -gt 0 ]; do
    case $1 in
    -s)
        sign=true
        ;;
    -i)
        shift
        repo=$1
        ;;
    armel)
        export CC=arm-linux-gnueabi-gcc
        arch=$1
        ;;
    *)
        usage $0
        ;;
    esac
    shift
done

script=${0##*/}

sdir=$(dirname $0)
cd $sdir
sdir=$PWD

giturl=https://github.com/openembedded/meta-openembedded.git

tmpdir=$(mktemp -d /tmp/${script}_XXXXXX)
trap "{ rm -rf $tmpdir; }" EXIT

cd $tmpdir

git clone $giturl

cd meta-openembedded/meta-oe/recipes-support/pxaregs/pxaregs-1.14 || exit 1

# The original debian directory was created with:
#   dh_make --native --single

rsync -a $sdir/debian .
rsync -a $sdir/Makefile .


debuild -aarmel -k"$key"

cd ..

changes=pxaregs_*_armel.changes

pkgs=$(grep "^Binary:" $changes | sed -e s/Binary://)
archs=$(grep "^Architecture:" $changes | sed -e 's/Architecture: *//' | tr \  "|")

if [ -n "$repo" ]; then
    umask 0002
        
    flock $repo sh -c "
        reprepro -V -b $repo -A '$archs' remove jessie $pkgs;
        reprepro -b $repo deleteunreferenced;
        reprepro -V -b $repo -A '$archs' include jessie $changes"
else
    cp pxaregs_*.build pxaregs_*.changes pxaregs_*.deb pxaregs_*.dsc pxaregs_*.tar.tz $sdir
    echo "Results in $sdir"
fi
