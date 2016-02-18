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

newconfig=${config}.new
cp .config ../$newconfig

echo "config saved as $newconfig"
