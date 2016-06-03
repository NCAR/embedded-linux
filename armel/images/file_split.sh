#!/bin/bash

set -e

if [ $# -lt 1 ]; then
    echo "Usage: ${0##*/} imagefile"
    exit 1
fi

file=$1

size=$(stat -c %s $file)
partsize=$(( 32 * 1024 * 1024 ))
bufsize=8192
nbufread=$(( $partsize / $bufsize ))
nbuftot=$(( ($size + $bufsize - 1) / $bufsize ))

part=1
for (( nbuf=0; nbuf < $nbuftot; nbuf += $nbufread )); do
    echo "size=$size, nbuf=$nbuf, nbufread=$nbufread"
    ofile=$(printf $file.p%02d $part)
    dd if=$file bs=$bufsize skip=$nbuf count=$nbufread of=$ofile

    let part++
done
