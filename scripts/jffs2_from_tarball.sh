#!/bin/sh

# untar a tarball to a temp directory, then generate
# a jffs2 image from it.
# mkfs.jffs2 is in the mtd-utils package on RedHad and Debian

if [ $# -lt 2 ]; then
    echo "Usage ${0##*/} tar_file output_image"
    exit 1
fi

tarfile=$1
oimage=$2

set -e

tmpdir=$(mktemp -d /tmp/${0##*/}_XXXXXX)
tmpimg=$(mktemp /tmp/${0##*/}_XXXXXX)
trap "{ sudo rm -rf $tmpdir $tmpimg; }" EXIT

sudo tar xJSf $tarfile -C $tmpdir

# Titan flash is NAND, so use --no-cleanmarkers
# pad is the desired size of the image:  0x1FA0000 for the titan
# eraseblock size is 128 KiB

# board     type    image size  eraseblock
# titan     NAND    0x1FA0000   0x20000=128 KiB
# viper     tbd     tbd         tbd

sudo mkfs.jffs2 --pad=0x1FA0000 --root=$tmpdir --output=$tmpimg \
    --eraseblock=0x20000 --little-endian --no-cleanmarkers

# $tmpimg is owned by root
cp $tmpimg $oimage
