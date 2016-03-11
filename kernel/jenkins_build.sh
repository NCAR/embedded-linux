#!/bin/bash

if [ $# -lt 1 ]; then
    echo "$0 repository"
    exit 1
fi

# repo=/net/ftp/pub/temp/users/maclean/debian
repo=$1

# Build kernel for a config file if the md5sum of
# the config file has changed.

# CONFIG_LOCALVERSION is typically set to viper2 or titan2 in
# the configs. The idea is that the viper1 and titan1 kernels
# are trusted backup kernels on the armel systems which can be
# used to recover a system if a new kernel won't boot.
# So make all changes with CONFIG_LOCAL_VERSION set to viper2, titan2.

# The viper1 and titan1 kernels can be updated from time to time
# with significant fixes if you know the version 2 kernel boots
# dependably.


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

git_kernel_version() {
    cd linux-stable-armel > /dev/null
    git describe --match '[vV][0-9]*'
    cd - > /dev/null
}

kernelver=$(git_kernel_version);

check_all() {
    for f in $@; do
        check_md5 $f || return 1
    done
    [ -f .kernel_version ] && kernelverprev=$(< .kernel_version)
    [ "$kernelverprev" == "$kernelver" ] || return 1
    return 0
}

save_all() {
    for f in $@; do
        save_md5 $f
    done
    echo $kernelver > .kernel_version
}

# Complain early if gpg-agent file can't be found
[ -e $HOME/.gpg-agent-info ] || echo "Warning: $HOME/.gpg-agent-info not found"

# do a build if the config file, the build script or the kernel have changed.
for file in config-3.16-titan config-3.16-viper; do
    if ! check_all $file build_dpkg.sh > /dev/null; then
        ./build_dpkg.sh -s -i $repo $file && save_all $file build_dpkg.sh
    else
        echo "No changes to $file, build_dpkg.sh or linux-stable-armel since last build"
    fi
done

