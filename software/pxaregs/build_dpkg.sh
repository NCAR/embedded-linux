#!/bin/sh

pkg=pxaregs

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

args="-a$arch"
karg=
if $sign; then
    export GPG_AGENT_INFO
    if [ -e $HOME/.gpg-agent-info ]; then
        . $HOME/.gpg-agent-info
    else
        echo "Warning: $HOME/.gpg-agent-info not found"
    fi
    karg=-k"$key"
else
    args="$args -us -uc"
fi

rm -f ${pkg}_*_$arch.changes

tar xzf ${pkg}_1.14.orig.tar.gz

cd ${pkg}-1.14


debuild $args "$karg"

cd ..

changes=${pkg}_*_armel.changes

pkgs=$(grep "^Binary:" $changes | sed -e s/Binary://)
archs=$(grep "^Architecture:" $changes | sed -e 's/Architecture: *//' | tr \  "|")

if [ -n "$repo" ]; then
    umask 0002
        
    flock $repo sh -c "
        reprepro -V -b $repo -A '$archs' remove jessie $pkgs;
        reprepro -b $repo deleteunreferenced;
        reprepro -V -b $repo -A '$archs' include jessie $changes"
else
    echo "Results in $sdir"
fi
