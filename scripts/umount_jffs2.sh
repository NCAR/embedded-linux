#!/bin/sh

# umount a JFFS2 file system and remove the kernel modules

if [ $# -lt 1 ]; then
    echo "Usage ${0##*/} mntpt"
    exit 1
fi

mntpt=$1

sudo umount $mntpt;
sudo modprobe -r mtdblock
sudo modprobe -r mtdram

