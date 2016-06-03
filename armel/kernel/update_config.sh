#!/bin/sh

# simple script to run menuconfig on a config file

if [ $# -lt 1 ]; then
    echo "Usage ${0##*/} config"
    exit 1
fi

config=$1

cp $config linux-stable-armel/.config

cd linux-stable-armel

make ARCH=arm menuconfig

cd -

oldconfig=${config}.old

i=1
while [ -f $oldconfig ]; do
    oldconfig=${config}.old$i
    i=$((i + 1))
done

echo "Saving $config as $oldconfig"
mv $config $oldconfig

cp linux-stable-armel/.config $config

echo "New config copied to $config"
