#!/bin/bash

set -e

key='<eol-prog@eol.ucar.edu>'

usage() {
    echo "Usage: ${1##*/} [-s] [-i repository ] arch"
    echo "-s: sign the package files with $key"
    echo "-f: fetch source package"
    echo "-c: build in a chroot"
    echo "-i: install them with reprepro to the repository"
    echo "arch is armel, armhf or amd64"
    exit 1
}

if [ $# -lt 1 ]; then
    usage $0
fi

sign=false
fetch=false
arch=amd64
args="--no-tgz-check -sa"
use_chroot=false
while [ $# -gt 0 ]; do
    case $1 in
    -i)
        shift
        repo=$1
        ;;
    -f)
        fetch=true
        ;;
    -c)
        use_chroot=true
        ;;
    -s)
        sign=true
        ;;
    armel)
        export CC=arm-linux-gnueabi-gcc
        arch=$1
        ;;
    armhf)
        export CC=arm-linux-gnueabihf-gcc
        arch=$1
        ;;
    amd64)
        arch=$1
        ;;
    *)
        usage $0
        ;;
    esac
    shift
done

set -x

$fetch && apt-get source chrony
# results in
# drwxrwxr-x 7 maclean eol   4096 Jun  6 17:00 chrony-1.30
# -rw-rw-r-- 1 maclean eol  24376 Jan 14 12:35 chrony_1.30-2+deb8u1.debian.tar.xz
# -rw-rw-r-- 1 maclean eol   1610 Jan 14 12:35 chrony_1.30-2+deb8u1.dsc
# -rw-rw-r-- 1 maclean eol 389130 Aug 10  2014 chrony_1.30.orig.tar.gz


# clean old results
rm -f $(echo chrony\*_{$arch,all}.{deb,build,changes})

args="$args -a$arch"

if $use_chroot; then
    dist=$(lsb_release -c | awk '{print $2}')
    if [ $arch == amd64 ]; then
        chr_name=${dist}-amd64-sbuild
    else
        chr_name=${dist}-amd64-cross-${arch}-sbuild
    fi
    if ! schroot -l | grep -F chroot:${chr_name}; then
        echo "chroot named ${chr_name} not found"
        exit 1
    fi
fi

chrony_source_dir=$(find . -mindepth 1 -maxdepth 1 -name "chrony-*" -type d)

if ! [ $chrony_source_dir ]; then
    echo "Cannot find unpacked chrony directory"
    exit 1
fi

cd $chrony_source_dir || exit 1

karg=
if $sign; then
    if [ -z "$GPG_AGENT_INFO" -a -f $HOME/.gpg-agent-info ]; then
        . $HOME/.gpg-agent-info
        export GPG_AGENT_INFO
    fi
    karg=-k"$key"
else
    args="$args -us -uc"
fi

if $use_chroot; then
    echo "Starting schroot, which takes some time ..."
    schroot -c $chr_name --directory=$PWD << EOD
        set -e
        [ -f $HOME/.gpg-agent-info ] && . $HOME/.gpg-agent-info
        export GPG_AGENT_INFO
        export CC=$CC
        # export DEB_BUILD_OPTIONS="--enable-debug"
        dpkg-buildpackage -a $arch -b
EOD
fi

cd ..

if [ -n "$repo" ]; then
    umask 0002
    chngs=chrony_*_$arch.changes 
    pkgs=$(grep "^Binary:" $chngs | sed 's/Binary: //')

    flock $repo sh -c "
        reprepro -V -b $repo include jessie $chngs"

    rm -f chrony_*_$arch.build chrony_*.dsc chrony_*.tar.?z chrony*_all.deb chrony*_$arch.deb $chngs

else
    echo "build results are in $PWD"
fi

$fetch && rm -rf $chrony_source_dir

