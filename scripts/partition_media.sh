#!/bin/sh

# partition a removeable disk with a Linux partition, type 83 (L)
# of a given size, and a second one containing the rest of the disk.

script=${0##*/}

usage() {
    echo "$script device [size]"
    echo "size: size in MiB of first partition.  Missing or <=0 means all, otherwise"
    echo "a second partition is also created up to the end-of-device"
    echo "Examples:
$script /dev/sdc
or
$script /dev/mmcblk0 1000
"
    exit 1
}

sizemb=0
[ $# -lt 1 ] && usage

dev=$1
[ $# -gt 1 ] && sizemb=$2

if [ $sizemb -le 0 ]; then
    fsizemb='-'
else
    fsizemb="${sizemb}MiB"
fi

ok=true
declare -A pdevs
if [[ $dev =~ /dev/mmcblk0 ]]; then
    [[ $dev =~ .+p[0-9] ]] && ok=false
    pdevs[root]=${dev}p1
    [ $sizemb -gt 0 ] pdevs[home]=${dev}p2
elif [[ $dev =~ /dev/sd[a-z] ]]; then
    [[ $dev =~ .+[0-9] ]] && ok=false
    pdevs[root]=${dev}1
    [ $sizemb -gt 0 ] && pdevs[home]=${dev}2
else
    echo "Unknown device $dev"
    exit 1
fi

if ! $ok; then
    echo "Error: device name should not contain a partition number"
    echo "For example:  use /dev/sdc rather than /dev/sdc1"
    exit 1
fi

for label in ${!pdevs[*]}; do
    pdev=${pdevs[$label]}

    if mount | fgrep -q $pdev; then
        echo "Error: $pdev is mounted!"
        echo "Doing: umount $pdev"
        umount $pdev || exit 1
        mount | fgrep $pdev && exit 1
    fi
done

if mount | fgrep -q $dev; then
    echo "$dev is still mounted:"
    mount | fgrep $dev
    exit 1
fi

sudo partprobe $dev

tmpfile=$(mktemp --tmpdir ${script}_XXXXXX)
sffile=$(mktemp --tmpdir ${script}_XXXXXX)
trap "{ rm -f $tmpfile $sffile; }" EXIT

repart=false
echo "doing: sudo sfdisk -V $dev"
sudo sfdisk -V -l $dev > $tmpfile 2>&1 || repart=true

echo "Output of sfdisk -l -V $dev" | cat - $tmpfile
echo "END"

if ! $repart; then

    if fgrep -q Warning $tmpfile; then
        # ignore warning about bootable
        fgrep Warning $tmpfile | fgrep -v -q bootable && repart=true
    fi

    grep -i -q Error $tmpfile && repart=true

    egrep '^/dev' $tmpfile | awk 'NR==1{print $7,$8}' | fgrep -q "Linux" || repart=true
    sizeword=$(( $(egrep '^/dev' $tmpfile | head -n 1 | wc -w) - 2))
    egrep '^/dev' $tmpfile | awk 'NR>1{if ($7 != "Linux") exit 1}' || repart=true

    # check size of partition
    size=$(egrep '^/dev' $tmpfile | head -n 1 | awk '{ print $'$sizeword'}')
    echo "size of first partition is $size"
    [ $size == ${sizemb}M ] || repart=true

fi

if $repart; then

    sudo partprobe -s $dev

    echo "Re-partitioning"

    echo "-,${fsizemb},L" > $sffile
    [ "$fsizemb" != - ] && echo "-,,L" >> $sffile

    echo "sfdisk partitioning input:" | cat - $sffile
    echo "END"

    echo "doing: sudo sfdisk -q $dev"
    # Tends to show this error:
    # Re-reading the partition table failed.: Device or resource busy
    # See if --no-reread and --no-tell-kernel options help.
    sudo sfdisk -q --no-reread --no-tell-kernel $dev < $sffile || exit 1
    echo "Partitioning success, calling partprobe"
    sudo partprobe -s $dev
    echo "partprobe done"
else
    echo "Partitions OK"
fi

