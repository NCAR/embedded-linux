#!/bin/sh -e

if [ $# -lt 2 ]; then
    echo "Usage ${0##*/} device p2size"
    echo "p2size is something like 4G"
    exit 1
fi

fdev=$1
sizep2=$2

# How big to make the image. one sector=512 bytes
# 8GB Kingston: 15564800 sectors
# 8GB Sandisk:  15523840 sectors (40960 sectors smaller)
target_size=15523840

tmpfile=$(mktemp)
trap "{ rm -f $tmpfile; }" EXIT

fdisk -l $fdev > $tmpfile || exit 1

disk_size=$(sed -n -r -e "/^Disk \/dev\/${fdev##*/}:/s/.* ([0-9]+) sectors/\1/p" $tmpfile)
echo "target_size=$target_size sectors, size of this disk=$disk_size"

if [ $disk_size -lt $target_size ]; then
    echo "Disk is $disk_size sectors, smaller than target_size=$target_size"
    exit 1
fi

startp2=$(grep ${fdev}p2 $tmpfile | awk '{print $2}')

# delete partitions 2 and above, create new partition 2 of requested size
npart=$(grep "^$fdev" $tmpfile | wc -l)

cat /dev/null > $tmpfile
for (( n=$npart; n >= 2; n-- )); do
    echo "d" >> $tmpfile
    echo "$n" >> $tmpfile
done

cat << EOD >> $tmpfile
n
p
2
$startp2
+$sizep2
w
EOD

fdisk $fdev > /dev/null < $tmpfile

endp2=$(fdisk -l $fdev | grep ${fdev}p2 | awk '{print $3}')
startp3=$(( $endp2 + 1 ))
sizep3=$(( $target_size - $startp3 ))

fdisk $fdev > /dev/null << EOD 
n
p
3
$startp3
+$sizep3
w
EOD

fdisk -l $fdev

resize2fs ${fdev}p2
mkfs.ext4 -F ${fdev}p3

