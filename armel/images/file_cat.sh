#!/bin/bash

set -e

if [ $# -lt 1 ]; then
    echo "Usage: ${0##*/} imagefile"
    exit 1
fi


file=$1

for part in $file.p*; do
    cat $part
done > $file
