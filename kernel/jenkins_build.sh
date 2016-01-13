#!/bin/sh

# Build kernel for a config file if the md5sum of
# the config file has changed.

# If you just change a simple thing like adding a kernel module
# to the config and are confident that it won't break things on the
# target system (i.e. are brave and foolish) then you can
# make that change without changing CONFIG_LOCALVERSION in
# the file.

# If you have made significant changes and you don't want the
# new kernel to overwrite the old on the target system, then
# also change CONFIG_LOCALVERSION in the config.

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

# for file in config-3.16-titan config-3.16-viper; do
for file in config-3.16-titan; do
    if ! check_md5 $file; then
        ./build_dpkg.sh $file && save_md5 $file
    else
        echo "No changes to $file since last build"
    fi
done

