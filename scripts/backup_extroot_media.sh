#!/bin/sh

# Script to create a tar backup of the usr, var and opt directories on
# an SD or CF flash card, which are used on armel embedded systems.
if [ $# -lt 2 ]; then
    echo "Usage: $0 mountpoint tarfile"
    echo "mountpoint: where SD/CF media is mounted"
    echo "A tar backup called  <tarfile>.xz will be created"
    echo "Note this script should be run from root or sudo"
    exit 1
fi

while [ $# -gt 0 ]; do
    case $1 in
    / | /.)
        echo "Don't run this on /!"
        exit 1
        ;;
    *)
        if [ $mntpt ]; then
            tarfile=$1
        else
            mntpt=$1
        fi
        ;;
    esac
    shift
done

set -e

mount | fgrep $mntpt

excfile=$(mktemp /tmp/${0##*/}_XXXXXX)
tmptar=$(mktemp /tmp/${0##*/}_XXXXXX).tar.xz
trap "{ rm $excfile $tmptar; }" EXIT

# /etc/init.d/bootlogs complains if this file is missing.
# It's the only file in var/log that we backup
cat /dev/null > var/log/dmesg

# don't backup these directories or files
cat > $excfile << EOD
var/backups
var/lib/chrony
var/lib/dbus 
var/lib/dhcpd5
var/lib/logrotate 
var/lib/ntp 
var/lib/urandom 
var/log
var/spool/cron
var/tmp
EOD

sudo tar Jcf $tmptar -C $mntpt -X $excfile var usr opt var/log/dmesg

# $tmptar is owned by root
cp $tmptar $tarfile

chmod +r $tarfile
