#!/bin/bash

# remove some content from a media containing Linux
# var, lib and opt directories

if [ $# -lt 1 ]; then
    echo "Usage ${0##*/} dir"
    exit 1
fi

rootdir=$1

set -e

cd $rootdir

service rsyslog stop
service chrony stop

cd var/log

for f in auth.log btmp daemon.log debug dmesg* kern.log lastlog messages syslog user.log wtmp; do
    rm -f ${f}.*
    cat /dev/null > $f
done

rm -f chrony/*

cd -

rm -f etc/udev/rules.d/70-persistent-net.rules

history -c
rm -f root/.bash_history root/.viminfo

sync; sync; sync
