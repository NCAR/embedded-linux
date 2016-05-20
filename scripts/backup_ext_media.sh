#!/bin/sh

# Script to create a tar backup of the usr, var and opt directories on
# an SD or CF flash card, which are used on armel embedded systems.
if [ $# -lt 2 ]; then
    echo "Usage: $0 mountpoint tarfile"
    echo "mountpoint: where SD/CF media is mounted"
    echo "A tar backup called  <tarfile>.xz will be created"
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

excfile=$(mktemp --tmpdir ${0##*/}_XXXXXX)
tmptar=$(mktemp --tmpdir ${0##*/}_XXXXXX).tar.xz
tmpdir=$(mktemp -d --tmpdir ${0##*/}_XXXXXX)
tmpfile=$(mktemp --tmpdir ${0##*/}_XXXXXX)
trap "{ rm -f $excfile $tmptar $tmpfile; }" EXIT

# don't backup these directories or files
cat > $excfile << EOD
lost+found
var/backups
var/lib/chrony
var/lib/dbus 
var/lib/dhcpd5
var/lib/logrotate 
var/lib/ntp 
var/lib/urandom 
var/spool/cron
var/tmp
var/log/*.gz
var/log/*.[0-9]
var/log/*.[0-9][0-9]
var/log/chrony
.bash_history
EOD

# Since we want to fiddle with files, rsync to a tmpdir
# change things, then create the tar

pushd $mntpt > /dev/null
sudo rsync -a --exclude-from=$excfile var usr opt $tmpdir

pushd $tmpdir > /dev/null

# empty file
cat /dev/null > $tmpfile

sudo cp $tmpfile var/log/lastlog
[ -d var/lib/dbus ] || sudo mkdir var/lib/dbus

sudo tar cJf $tmptar opt usr var

popd > /dev/null
popd > /dev/null

# $tmptar is owned and rw only by root
sudo chmod ugo+r $tmptar

cp $tmptar $tarfile

sudo rm $tmptar

