#!/bin/bash -ex

pkg=ptpv1d

key="<eol-prog@eol.ucar.edu>"

usage() {
    echo "Usage: ${1##*/} [-s] [-i repository ] arch"
    echo "-s: sign the package files with key=$key"
    echo "-c: build in a chroot"
    echo "-i: install them with reprepro to the repository"
    echo "arch is armel or armhf"
    exit 1
}

if [ $# -lt 1 ]; then
    usage $0
fi

sign=false
use_chroot=false
arch=armel
while [ $# -gt 0 ]; do
    case $1 in
    -c)
        use_chroot=true
        ;;
    -s)
        sign=true
        ;;
    -i)
        shift
        repo=$1
        ;;
    armel)
        export CC=arm-linux-gnueabi-gcc
        arch=$1
        ;;
    armhf)
        export CC=arm-linux-gnueabihf-gcc
        arch=$1
        ;;
    *)
        usage $0
        ;;
    esac
    shift
done

if $use_chroot; then
    dist=$(lsb_release -c | awk '{print $2}')
    if [ $arch == amd64 ]; then
        chr_name=${dist}-amd64-sbuild
    else
        chr_name=${dist}-amd64-cross-${arch}-sbuild
    fi
    if ! schroot -l | grep -F chroot:${chr_name}; then
        echo "chroot named ${chr_name} not found"
        exit 1
    fi
fi

sdir=$(dirname $0)
cd $sdir
sdir=$PWD

args="-a$arch -sa"

karg=
if $sign; then
    export GPG_AGENT_INFO
    if [ -e $HOME/.gpg-agent-info ]; then
        . $HOME/.gpg-agent-info
    else
        echo "Warning: $HOME/.gpg-agent-info not found"
    fi
    karg=-k"$key"
else
    args="$args -us -uc"
fi

rm -f ${pkg}_*_$arch.changes

tar xJf ${pkg}_1.0.orig.tar.xz

cd ${pkg}-1.0

if ! gitdesc=$(git describe --match "v1.0"); then
    echo "git describe failed, looking for a tag of the form v1.0"
    exit 1
fi  

release=${gitdesc%-*}
release=${release#*-}

user=$(git config --get user.name)
email=$(git config --get user.email)

rm -f debian/changelog
cat > debian/changelog << EOD
ptpv1d (1.0-$release) stable; urgency=low

  * Update

 -- $user <$email>  $(date -R)
EOD
cat debian/initial_changelog >> debian/changelog

if $use_chroot; then
    echo "Starting schroot, which takes some time ..."
    schroot -c $chr_name --directory=$PWD << EOD
        set -e
        [ -f $HOME/.gpg-agent-info ] && . $HOME/.gpg-agent-info
        export GPG_AGENT_INFO
        debuild $args "$karg"
EOD
else
    debuild $args "$karg"
fi

cd ..

set -x

if [ -n "$repo" ]; then
    umask 0002

    echo "Build results:"
    ls
    echo ""

    changes=${pkg}_*_${arch}.changes
    echo "Changes file: $changes"
    cat $changes
    echo ""

    flock $repo sh -e -c "
        reprepro -V -b $repo -C main include jessie $changes;
        reprepro -b $repo deleteunreferenced"

    rm -f ${pkg}_*_$arch.build ${pkg}_*.dsc ${pkg}*_$arch.deb $changes

else
    echo "Results in $sdir"
fi
