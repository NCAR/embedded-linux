#!/bin/sh

# copy an image from a flash device

if [ $# -lt 2 ]; then
    echo "Usage ${0##*/} device imagefile"
    exit 1
fi

fdev=$1
dest=$2

set -e

[[ $dest =~ /.* ]] || dest=$PWD/$dest

doxz=false
[ ${dest##*.} == xz ] && doxz=true

$doxz && dest=${dest%.*}

fs="$(mount | grep "^$fdev" | awk '{print $3}')"

if [ -n "$fs" ]; then
    echo "Umounting file systems on $fdev"
    umount $(mount | grep "^$fdev" | awk '{print $3}')
fi

tmpfile=$(mktemp --tmpdir ${0##*/}_XXXXXX.img)
tmpfile2=$(mktemp --tmpdir ${0##*/}_XXXXXX.img)
bmapfile=$(mktemp --tmpdir ${0##*/}_XXXXXX.bmap)
trap "{ rm -f $tmpfile $tmpfile2 $bmapfile; }" EXIT

# Determine last sector of partitions, only extract up to that.
# Image should then fit on all disks of at least that size
sudo fdisk -l $fdev > $tmpfile || exit 1
lastsect=$(awk 'ENDFILE{print $3}' $tmpfile)

blocksize=512
count=$lastsect
for fact in 5 10 20 50 100 200 500; do
    [ $(( $lastsect % $fact )) -ne 0 ] && break
    blocksize=$(( 512 * $fact ))
    count=$(( $lastsect / $fact ))
done

echo "Extracting image, #sectors=$lastsect, blocksize=$blocksize, count=$count"
sudo dd if=$fdev of=$tmpfile bs=$blocksize count=$count

echo "Creating sparse image file"
cp --sparse=always $tmpfile $tmpfile2

echo "Creating bmap file"
bmaptool create -o $bmapfile $tmpfile2


if $doxz; then
    echo "Compressing. This will take some time..."
    xz -c $tmpfile2 > $dest.xz
else
    mv $tmpfile2 $dest
fi

cp $bmapfile ${dest%.*}.bmap
chmod +rw ${dest%.*}.bmap

