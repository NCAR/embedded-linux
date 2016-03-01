#!/bin/bash

# generate a jffs2 image from a directory
# mkfs.jffs2 is in the mtd-utils package on RedHad and Debian

usage() {
    echo "Usage ${0##*/} viper|titan tmpdir output_image"
    exit 1
}

if [ $# -lt 3 ]; then
    usage
fi

mach=$1
case $mach in
    viper|titan)
        ;;
    *)
        usage
        ;;
esac

indir=$2
oimage=$3

suff=${oimage##*.}
if [ "$suff" != img ]; then
    echo "Output image should end in .img"
    exit 1
fi

set -e

tmpimg=$(mktemp /tmp/${0##*/}_XXXXXX)
trap "{ sudo rm -rf $tmpimg; }" EXIT

cd $indir
# remove xmlrpc++, nidas and other local packages
#   (including /etc/modprobe.d/diamond)
# depmod -a
# set root,dac password to default, ncareol

sudo rm -f etc/udev/rules.d/70-persistent-net.rules
sudo rm -f etc/apt/sources.list.d/eol.list

# restore etc/shadow file with default "ncareol" password
sudo sed -i -e 's,^root.*$,root:$6$hJd8qazV$uZ7mvMXhXpVybc9vJ/VHuu57UUzBD.lrrdRsIAX5huoQqxkPPgJKyvPmBpsaS1BB,' etc/shadow
# dac:$6$VkMAnAKw$O8F4H8bdmlz/./7nv0y3Btla/d.pAcvTNPvpKraGWxBl.FkFdcQbbBYYwWHE/UUhhQ.f.VoMSuWwtWioOLAql0.:16846:0:99999:7:::


# viper and titan flash is NAND, so use --no-cleanmarkers
# pad is the desired size of the image:  0x1FA0000 for the titan
# eraseblock size is 128 KiB

# board     type    image size  eraseblock
# titan     NAND    0x1FA0000   0x20000=128 KiB
# viper     NAND    0x1FE0000   0x20000=128 KiB

cd -

declare -A pad
pad[titan]=0x1FA0000
pad[viper]=0x1FE0000

sudo mkfs.jffs2 --pad=${pad[$mach]} --root=$indir --output=$tmpimg \
    --eraseblock=0x20000 --little-endian --no-cleanmarkers

# $tmpimg is owned by root
sudo chown $USER $tmpimg
sudo chmod g+wr $tmpimg
sudo chmod +r $tmpimg
cp $tmpimg $oimage
