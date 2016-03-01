#!/bin/sh

# untar a tarball to a temp directory
# Root must have write access to the tmpdir, therefore it probably can't be
# on an NFS filesystem.

usage() {
    echo "Usage ${0##*/} tar_file tmpdir"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

tarfile=$1
dir=$2

if [ -d $dir ]; then
    echo "$dir exists"
    exit 1
fi

set -e

mkdir -p $dir

sudo tar xJSf $tarfile -C $dir

# remove xmlrpc++, nidas and other local packages
#   (including /etc/modprobe.d/diamond)
# depmod -a
# set root,dac password to default, ncareol

sudo rm -f etc/udev/rules.d/70-persistent-net.rules
sudo rm -f etc/apt/sources.list.d/eol.list

# restore etc/shadow file with default "ncareol" password
sudo sed -i -e 's,^root.*$,root:$6$hJd8qazV$uZ7mvMXhXpVybc9vJ/VHuu57UUzBD.lrrdRsIAX5huoQqxkPPgJKyvPmBpsaS1BB,' etc/shadow
# dac:$6$VkMAnAKw$O8F4H8bdmlz/./7nv0y3Btla/d.pAcvTNPvpKraGWxBl.FkFdcQbbBYYwWHE/UUhhQ.f.VoMSuWwtWioOLAql0.:16846:0:99999:7:::

