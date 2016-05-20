#!/bin/bash

# generate a jffs2 image from a directory
# mkfs.jffs2 is in the mtd-utils package on RedHad and Debian

usage() {
    echo "Usage ${0##*/} viper|titan tmproot output_image"
    exit 1
}

if [ $# -lt 3 ]; then
    usage
fi

mach=$1
case $mach in
    viper|titan)
        ;;
    *)
        usage
        ;;
esac

indir=$2
oimage=$3

suff=${oimage##*.}
if [ "$suff" != img ]; then
    echo "Output image should end in .img"
    exit 1
fi

set -e

tmpimg=$(mktemp --tmpdir ${0##*/}_XXXXXX)
trap "{ sudo rm -rf $tmpimg; }" EXIT

declare -A pad
pad[titan]=0x1FA0000
pad[viper]=0x1FE0000

sudo mkfs.jffs2 --pad=${pad[$mach]} --root=$indir --output=$tmpimg \
    --eraseblock=0x20000 --little-endian --no-cleanmarkers

# $tmpimg is owned by root
sudo chown $USER $tmpimg
sudo chmod g+wr $tmpimg
sudo chmod +r $tmpimg
cp $tmpimg $oimage
