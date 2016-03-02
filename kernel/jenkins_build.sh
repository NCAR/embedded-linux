#!/bin/sh

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

export GPG_AGENT_INFO
if [ -e $HOME/.gpg-agent-info ]; then
    . $HOME/.gpg-agent-info
else
    echo "Warning: $HOME/.gpg-agent-info not found"
fi

for file in config-3.16-titan config-3.16-viper; do
    if ! check_md5 $file > /dev/null; then
        ./build_dpkg.sh -s -i $repo $file && save_md5 $file
    else
        echo "No changes to $file since last build"
    fi
done

