#!/bin/sh

# Run bash in debian-armel-kern-cross:jessie image, copying portions of this git working
# directory, including linux-stable, to /tmp/$USER and sharing it as a docker volume
# in the docker user's home directory

[ -d /tmp/$USER ] || mkdir /tmp/$USER

if false; then
    # top level of git working dir
    gitpath=$(git rev-parse --show-toplevel)
    repo=${gitpath##*/}
    gitpath=${gitpath%/*}
    kernpath=$gitpath/linux-stable-armel


    rsync -a --exclude .git --exclude packages --exclude linux-stable-armel \
        $gitpath/$repo /tmp/$USER || exit 1
    rsync -a --exclude .git $kernpath /tmp/$USER/$repo/kernel || exit 1
fi

if [ $(getenforce) == Enforcing ]; then
    echo "You must do 'sudo setenforce permissive'"
    echo "Otherwise debian fakeroot command doesn't work on shared volumne"
    exit 1
fi

# Assumes docker user in image is armcross, with a $HOME of /home/armcross
# Could get fancy and fetch those values with docker inspect

docker run --rm -v /tmp/$USER:/home/armcross/docker:rw,Z -i -t debian-armel-kern-cross:jessie /bin/bash

