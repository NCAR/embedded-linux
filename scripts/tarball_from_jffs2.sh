#!/bin/sh

# mount a JFFS2 file system, then create a tar backup

if [ $# -lt 2 ]; then
    echo "Usage ${0##*/} input_image tar_file"
    exit 1
fi

iimage=$1
tarfile=$2

set -e

PATH=$PATH:/sbin
sudo modinfo mtdram
sudo modprobe mtdram total_size=32384 erase_size=128
sudo modprobe mtdblock
sudo dd if=$iimage of=/dev/mtdblock0

mntpt=$(mktemp -d /tmp/${0##*/}_XXXXXX)
trap "{ rmdir $mntpt; }" EXIT

sudo mount -t jffs2 /dev/mtdblock0 $mntpt

trap "{ sudo umount $mntpt; rmdir $mntpt; }" EXIT

cd $mntpt

# On titan before netcatting /:
# remove xmlrpc++ and nidas packages
# depmod -a
# set root password to default

# var is on external drive
# pushd var/log > /dev/null || exit 1
# 
# for prefix in alternatives auth daemon debug dpkg kern messages syslog user.log; do
#     sudo rm -f ${prefix}.*
#     sudo cat /dev/null > $prefix
# done
# sudo rm -rf chrony/*
# popd > /dev/null || exit 1

sudo rm -f etc/udev/rules.d/70-persistent-net.rules

# Also should restore a etc/password file with default "ncareol" passwords

tartmp=$(mktemp /tmp/${0##*/}_XXXXXX).tar.xz
trap "{ sudo umount $mntpt; rmdir $mntpt; rm -f $tartmp; }" EXIT

sudo tar cJSf $tartmp .
# tar: ./dev/log: socket ignored

cd -

trap "{ rmdir $mntpt; sudo rm -f $tartmp; }" EXIT
sudo umount $mntpt

sudo modprobe -r mtdblock
sudo modprobe -r mtdram

cp $tartmp $tarfile

