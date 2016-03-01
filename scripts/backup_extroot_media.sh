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
trap "{ rm -f $excfile $tmptar; }" EXIT

# Can't figure out how to exclude var/log, but include var/log/dmesg
# /etc/init.d/bootlogs complains if this file is missing.
# It's the only file in var/log that we backup
# sudo sh -c "cat /dev/null > $mntpt/var/log/dmesg"
# --exclude-tag=var/log/dmesg didn't work
# try --exclude-tag=log/dmesg didn't work

# don't backup these directories or files
cat > $excfile << EOD
var/backups
var/lib/chrony
var/lib/dbus 
var/lib/dhcpd5
var/lib/logrotate 
var/lib/ntp 
var/lib/urandom 
var/spool/cron
var/tmp
.bash_history
EOD

sudo tar Jcf $tmptar -C $mntpt -X $excfile --exclude-tag=log/dmesg var usr opt

# $tmptar is owned and rw only by root
sudo chmod ugo+r $tmptar

cp $tmptar $tarfile

sudo rm $tmptar

