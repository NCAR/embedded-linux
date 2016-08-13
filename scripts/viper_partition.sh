#!/bin/sh -e

if [ $# -lt 2 ]; then
    echo "Usage ${0##*/} device p1size"
    echo "p1size is something like 850M"
    exit 1
fi

fdev=$1
sizep1=$2

# How big to make the image. one sector=512 bytes
# Use smallest size in sectors of target disks
# 1GB SanDisk SDCFX-10: 2001888 sectors
# 1GB Toshiba THNCF1G0: 2000880 sectors
target_size=2000880

tmpfile=$(mktemp)
trap "{ rm -f $tmpfile; }" EXIT

fdisk -l $fdev > $tmpfile || exit 1

disk_size=$(sed -n -r -e "/^Disk \/dev\/${fdev##*/}:/s/.* ([0-9]+) sectors/\1/p" $tmpfile)
echo "target_size=$target_size sectors, size of this disk=$disk_size"

if [ $disk_size -lt $target_size ]; then
    echo "Disk is $disk_size sectors, smaller than target_size=$target_size"
    exit 1
fi

# cat $tmpfile

startp1=$(grep ${fdev}1 $tmpfile | awk '{print $2}')

# delete all partitions, create new partition 1 of requested size
npart=$(grep "^$fdev" $tmpfile | wc -l)

cat /dev/null > $tmpfile
for (( n=$npart; n >= 2; n-- )); do
    echo "d" >> $tmpfile
    echo "$n" >> $tmpfile
done

echo "d" >> $tmpfile

startp1=2048

cat << EOD >> $tmpfile
n
p
1
$startp1
+$sizep1
w
EOD

cat $tmpfile

fdisk $fdev > /dev/null < $tmpfile

endp1=$(fdisk -l $fdev | grep ${fdev}1 | awk '{print $3}')
startp2=$(( $endp1 + 1 ))
sizep2=$(( $target_size - $startp2 ))

fdisk $fdev > /dev/null << EOD 
n
p
2
$startp2
+$sizep2
w
EOD

fdisk -l $fdev

mkfs.ext4 -F ${fdev}1
mkfs.ext4 -F ${fdev}2

