#!/bin/bash

# Build armel-images RPM if anything has changed

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

check_all() {
    for f in $@; do
        check_md5 $f || return 1
    done
    return 0
}

save_all() {
    for f in $@; do
        save_md5 $f
    done
}

# do a build if any of the files have changed
files=(armel-images.spec build_rpm.sh titan_*.img viper_*.img titan_*.tar.xz viper_*.tar.xz redboot-titan* redboot-viper*)

if ! check_all ${files[*]} > /dev/null; then
    ./build_rpm.sh -i && save_all ${files[*]}
else
    echo "No changes to ${files[*]} since last build"
fi

