#!/bin/sh

cp titan-config-2.6.35-ael1 linux-stable/.config
cd linux-stable

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- oldconfig

export KBUILD_PKG_ROOTCMD='fakeroot -u'

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- LOCALVERSION=-eol1 KDEB_PKGVERSION=$(make kernelversion)-1 V=1 deb-pkg

# linux-stable/localversion00-aeln  = -ael1
# CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO=y

# make kernelversion = 2.6.35
# make kernelrelease = 2.6.35-ael1-eol1-00003-g9389afd-dirty

# CONFIG_LOCALVERSION: appended after the contents of any
#   files with a filename matching localversion
# CONFIG_LOCALVERSION_AUTO
#   looks for git tags, string of the format -gxxxxxxxx after
#   CONFIG_LOCALVERSION

# above results in:
# linux-firmware-image_2.6.35-1_all.deb
# linux-image-2.6.35-ael1-eol1-00003-g9389afd-dirty_2.6.35-1_armel.deb

# If CONFIG_LOCALVERSION="" and CONFIG_LOCALVERSION_AUTO is not set,
# and remove localversion00-aeln
# linux-image-2.6.35-eol1_2.6.35-1_armel.deb

# linux-image deb package:
# /etc/kernel
# /usr/share/doc
# /boot/vmlinuz, config, System.map
# /lib/modules/2.6.35-ael1-eol1-00003-g9389afd-dirty

#  linux-firmware-image_2.6.35-1_all.deb
# /usr/share/doc
# /lib/firmware/edgeport    down.fw, down2.fw, boot.fw, boot2.fw

# target:
# headers_install - Install sanitised kernel headers to INSTALL_HDR_PATH
#   (default: /home/armcross/embedded-armel/kernel/linux-stable/usr)
# make a debian package out of them

# compile args. Note that -O over-rides -O2
# arm-linux-gnueabi-gcc -mlittle-endian -Iarch/arm/mach-pxa/include -Iarch/arm/plat-pxa/include  -O2 -marm -mabi=aapcs-linux -mno-thumb-interwork -O -D__LINUX_ARM_ARCH__=5 -march=armv5te -mtune=xscale -Wa,-mcpu=xscale -msoft-float -Uarm 

# Need to use gzip to create data.tar.gz instead of .xz
# dpkg-deb -Zgzip
# linux-stable/scripts/package/builddeb
# - dpkg --build "$pdir" ..
# + dpkg-deb -Zgzip --build "$pdir" ..

# stuff used by scripts/package/builddeb
# debian
#   copyright, changelog


# now to try to migrate to 3.2.x ...
