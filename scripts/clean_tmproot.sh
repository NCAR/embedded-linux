#!/bin/sh

# remove some content from tmpdir

tmpdir=${0%/*}

if [ $# -lt 1 ]; then
    echo "Usage ${0##*/} dir"
    exit 1
fi

tmpdir=$1

set -e

cd $tmpdir

sudo rm -rf etc/udev/rules.d/70-persistent-net.rules \
    root/.ssh/known_hosts root/.ssh/authorized_keys* \
    etc/apt/sources.list.d/eol.list \
    .viminfo .bash_history \
    root/.viminfo root/.bash_history \
    root/minicom.log \
    usr/* var/* opt/* \
    etc/ssh/ssh_host*key*

cat << EOL > etc/apt/sources.list
deb http://ftp.us.debian.org/debian/ jessie main

deb http://security.debian.org/ jessie/updates main

# jessie-updates, previously known as 'volatile'
# deb http://ftp.us.debian.org/debian/ jessie-updates main
EOL

# remove daq user, eol group

# Before netcatting the image:
# apt-get purge nidas nidas-builduser nidas-libs nidas-daq nidas-min nidas-modules-titan eol-daq xmlrpc++
# apt-get autoremove

# remove xmlrpc++, nidas and other local packages
#   (including /etc/modprobe.d/diamond)
# depmod -a
# set root,dac password to default, ncareol

# restore etc/shadow file with default "ncareol" password
# sudo sed -i -e 's,^root.*$,root:$6$hJd8qazV$uZ7mvMXhXpVybc9vJ/VHuu57UUzBD.lrrdRsIAX5huoQqxkPPgJKyvPmBpsaS1BB,' etc/shadow
# dac:$6$VkMAnAKw$O8F4H8bdmlz/./7nv0y3Btla/d.pAcvTNPvpKraGWxBl.FkFdcQbbBYYwWHE/UUhhQ.f.VoMSuWwtWioOLAql0.:16846:0:99999:7:::
