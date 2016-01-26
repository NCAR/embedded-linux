#!/bin/sh

# install a package to a debian repository

# Allow group writes
umask 0002

repo=/net/www/docs/software/debian
repo=/net/ftp/pub/temp/users/maclean/debian

if [ $# -lt 1 ]; then
    echo "Usage: ${0##*/} [-r repo] deb_files"
    echo "default repo=$repo"
    exit 1
fi

debs=
while [ $# -gt 0 ]; do
    case $1 in
    -r)
        shift
        repo=$1
        ;;
    *.deb)
        debs="$debs $1"
        ;;
    esac
    shift
done

pkgs=
for d in $debs; do
    pkg=${d%_*}
    pkg=${pkg%_*}
    echo "d=$d, pkg=$pkg"
    pkgs="$pkgs $pkg"

    # sign the package
    dpkg-sig --sign builder -k "<eol-prog@eol.ucar.edu>" $d
done

# get list of binary packages from .changes file
# pkgs=$(grep "^Binary:" $changes | sed -e s/Binary://)

# archs=$(grep "^Architecture:" $changes | sed -e 's/Architecture: *//' | tr \  "|")

flock $repo reprepro -b $repo deleteunreferenced

flock $repo reprepro -V -b $repo -C main -T deb remove jessie $pkgs

flock $repo reprepro -V -b $repo -C main includedeb jessie $debs
rm -f $debs

