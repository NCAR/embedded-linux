#!/bin/sh

# mount a JFFS2 file system image, rsync its contents to another directory.
# The directory should not exist.  Root must have permission to create
# and write to it, therefore it probably can't be on an NFS filesystem.

sdir=${0%/*}

if [ $# -lt 2 ]; then
    echo "Usage ${0##*/} input_image outputdir"
    exit 1
fi

iimage=$1
dir=$2

if [ -d $dir ]; then
    echo "$dir exists"
    exit 1
fi

set -e

mkdir -p $dir

mntpt=$(mktemp -d --tmpdir ${0##*/}_XXXXXX)
trap "{ rmdir $mntpt; }" EXIT

$sdir/mount_jffs2_image.sh $iimage $mntpt

trap "{ cd -; $sdir/umount_jffs2.sh $mntpt; rmdir $mntpt; }" EXIT

cd $mntpt

echo "$iimage mounted at $mntpt"
df -h .

sudo rsync -a . $dir
echo "$mntpt rsync'd to $dir"

