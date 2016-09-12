#!/bin/sh -xe

if [ $# -lt 2 ]; then
    echo "$0 repository arch"
    exit 1
fi

# repo=/net/ftp/pub/temp/users/maclean/debian
repo=$1
arch=$2

# directory containing script
srcdir=$(readlink -f ${0%/*})
hashfile=$srcdir/.last_hash_$arch
cd $srcdir

[ -f $hashfile ] && last_hash=$(cat $hashfile)
this_hash=$(git log -1 --format=%H .)
if [ "$this_hash" = "$last_hash" ]; then
    echo "No updates in $PWD since last build"
    exit 0
fi

export GPG_AGENT_INFO
[ -e $HOME/.gpg-agent-info ] && . $HOME/.gpg-agent-info

./build_dpkg.sh -s -i $repo $arch

status=$?
[ $status -eq 0 ] && echo $this_hash > $hashfile
exit $status

