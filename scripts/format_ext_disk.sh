#!/bin/sh

# script directory
sdir=${0%/*}

usage() {
    echo "${0##*/} device [sizeMiB]"
    echo "Example: ${0##*/} /dev/mmcblk0 1000"
    exit 1
}

[ $# -lt 1 ] && usage
dev=$1

sizemb=0
[ $# -gt 1 ] && sizemb=$2

mmcdev=false
if [[ $dev =~ /dev/mmcblk.* ]]; then
    mmcdev=true
    if [[ $dev =~ .*p[0-9] ]]; then
        echo "Error: device name should not contain a partition number"
        echo "For example:  use /dev/mmcblk0 rather than /dev/mmcblk0p1"
        exit 1
    fi
elif [[ $dev =~ /dev/sd.* ]]; then
    if [[ $dev =~ .*[0-9] ]]; then
        echo "Error: device name should not contain a partition number"
        echo "For example:  use /dev/sdc rather than /dev/sdc1"
        exit 1
    fi
else
    echo "Unknown disk type: $dev"
    exit 1
fi

$sdir/partition_media.sh $dev $sizemb || exit 1

declare -A pdevs
if $mmcdev; then
    pdevs[root]="${dev}p1"
    [ $sizemb -gt 0 ] && pdevs[home]="${dev}p2"
else
    pdevs[root]="${dev}1"
    [ $sizemb -gt 0 ] && pdevs[home]="${dev}2"
fi

for label in ${!pdevs[*]}; do
    pdev=${pdevs[$label]}
    if mount | fgrep -q $pdev; then
        echo "Error: $pdev is mounted!"
        mount | fgrep $part
        exit 1
    fi

    echo "doing mkfs.ext4 -L $label $pdev"
    sudo mkfs.ext4 -L $label $pdev
done
