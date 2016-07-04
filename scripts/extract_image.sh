#!/bin/sh

# copy an image from a flash device

if [ $# -lt 2 ]; then
    echo "Usage ${0##*/} device imagefile"
    exit 1
fi

dev=$1
dest=$2

set -e

[[ $dest =~ /.* ]] || dest=$PWD/$dest

doxz=false
[ ${dest##*.} == xz ] && doxz=true

$doxz && dest=${dest%.*}

tmpfile=$(mktemp --tmpdir ${0##*/}_XXXXXX.img)
tmpfile2=$(mktemp --tmpdir ${0##*/}_XXXXXX.img)
bmapfile=$(mktemp --tmpdir ${0##*/}_XXXXXX.bmap)
trap "{ rm -f $tmpfile $tmpfile2 $bmapfile; }" EXIT

sudo dd if=$dev of=$tmpfile bs=4M

cp --sparse=always $tmpfile $tmpfile2

bmaptool create -o $bmapfile $tmpfile2

bmaptool copy --bmap $bmapfile $tmpfile2 $dest

echo "Compressing. This will take some time..."

$doxz && xz $dest

cp $bmapfile ${dest%.*}.bmap
chmod +rw ${dest%.*}.bmap

