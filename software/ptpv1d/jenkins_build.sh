#!/bin/sh

if [ $# -lt 2 ]; then
    echo "$0 repository arch
    exit 1
fi

# repo=/net/ftp/pub/temp/users/maclean/debian
repo=$1
arch=$2

tmpdir=$(mktemp -d /tmp/${0##*/}_XXXXXX)
trap "{ rm -rf $tmpdir; }" EXIT

check_md5() {
    local file=$1
    local sumfile=.${file}_md5sum
    md5sum --quiet --check $sumfile 2>/dev/null
    return $?
}
save_md5() {
    local file=$1
    local sumfile=.${file}_md5sum
    md5sum $file > $sumfile
}

check_md5_dir() {
    local dir=$1
    local sumfile=.${dir}_md5sum
    tar cf $tmpdir/${dir}.tar --mtime="1970-1-1" $dir
    [ -f $sumfile ] && cp $sumfile $tmpdir
    cd $tmpdir
    md5sum --quiet --check $sumfile 2>/dev/null
    ok=$?
    cd -
    return $ok
}

save_md5_dir() {
    local dir=$1
    local sumfile=.${dir}_md5sum
    tar cf $tmpdir/${dir}.tar --mtime="1970-1-1" $dir
    cd $tmpdir
    md5sum ${dir}.tar > $sumfile
    cd -
    mv $tmpdir/$sumfile .
}

export GPG_AGENT_INFO
[ -e $HOME/.gpg-agent-info ] && . $HOME/.gpg-agent-info

dirs="ptpv1d-1.0"
files="build_dpkg.sh jenkins_build.sh ptpv1d_1.0.orig.tar.gz"

changed=false
for dir in $dirs; do
    check_md5_dir $dir || changed=true
done
for file in $files; do
    check_md5 $file > /dev/null || changed=true
done

if ! $changed; then
    echo "No changes since last build"
    exit
fi

./build_dpkg.sh -s -i $repo $arch || exit 1

for dir in $dirs; do
    save_md5_dir $dir
done
for file in $files; do
    save_md5 $file
done

