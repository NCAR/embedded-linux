#!/bin/sh

# Script to restore a tar backup to a mountpoint
if [ $# -lt 2 ]; then
    echo "Usage: $0 tarfile mountpoint"
    echo "tarfile: .xz tarfile to read"
    echo "mountpoint: where SD/CF media is mounted"
    exit 1
fi

while [ $# -gt 0 ]; do
    case $1 in
    / | /.)
        echo "Don't run this on /!"
        exit 1
        ;;
    *)
        if [ $tarfile ]; then
            mntpt=$1
        else
            tarfile=$1
        fi
        ;;
    esac
    shift
done

set -e

if ! mount | fgrep -q $mntpt; then
    echo "$mntpt does not seem to be mounted"
    exit 1
fi

sudo tar Jxf $tarfile -C $mntpt

echo "umounting $mntpt - wait for it to finish before removing media"
umount $mntpt

