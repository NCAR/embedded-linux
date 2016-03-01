#!/bin/sh

# mount a JFFS2 file system

if [ $# -lt 2 ]; then
    echo "Usage ${0##*/} input_image mntpt"
    exit 1
fi

iimage=$1
mntpt=$2

set -e

isize=$(stat -c %s $iimage)
# 33423360
tsize=$(( $isize / 1024 ))
echo "$iimage size=$isize B, $tsize KiB"

PATH=$PATH:/sbin
sudo modinfo mtdram
sudo modprobe mtdram total_size=$tsize erase_size=128
sudo modprobe mtdblock
sudo dd if=$iimage of=/dev/mtdblock0

sudo mount -t jffs2 /dev/mtdblock0 $mntpt

echo "$iimage mounted at $mntpt"

