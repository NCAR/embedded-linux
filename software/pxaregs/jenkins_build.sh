#!/bin/sh

if [ $# -lt 1 ]; then
    echo "$0 repository"
    exit 1
fi

# repo=/net/ftp/pub/temp/users/maclean/debian
repo=$1

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

dirs="pxaregs-1.14"
files="build_dpkg.sh jenkins_build.sh pxaregs_1.14.orig.tar.gz"

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

./build_dpkg.sh -s -i $repo armel || exit 1

for dir in $dirs; do
    save_md5_dir $dir
done
for file in $files; do
    save_md5 $file
done

