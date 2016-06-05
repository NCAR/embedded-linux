#!/bin/bash

# put tools in PATH
PATH=$PWD/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin:$PATH

cp config-rpi2 linux/.config

localv=

cd linux

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- oldconfig

# KERNEL=kernel7
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig

# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
    LOCALVERSION=$localv KDEB_PKGVERSION=1.0 \
    deb-pkg
