#!/bin/bash -e

# Build armel-images RPM if anything has changed

# directory containing script
srcdir=$(readlink -f ${0%/*})
cd $srcdir
hashfile=.last_hash

[ -f $hashfile ] && last_hash=$(cat $hashfile)
this_hash=$(git log -1 --format=%H .)

if [ "$this_hash" == "$last_hash" ]; then
    echo "No commits in $PWD since last build"
    exit 0
fi

./build_rpm.sh &&  echo $this_hash > $hashfile

