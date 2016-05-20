#!/bin/sh

# create a tar backup of a directory

if [ $# -lt 2 ]; then
    echo "Usage ${0##*/} dir tar_file"
    exit 1
fi

dir=$1
tarfile=$2
suff=${tarfile##*.}

if [ "$suff" != xz ]; then
    echo "tar file must be a tar.xz"
    exit 1
fi

set -e

tartmp=$(mktemp --tmpdir ${0##*/}_XXXXXX).tar.xz
trap "{ rm -f $tartmp; }" EXIT

cd $dir

sudo tar cJSf $tartmp .
# tar: ./dev/log: socket ignored

sudo chown $USER $tartmp

cd -

cp $tartmp $tarfile

