#!/bin/sh

# Run bash in debian-armel-kern-cross:jessie image, copying portions of this git working
# directory, including linux-stable, to /tmp/$USER and sharing it as a docker volume
# in the docker user's home directory

# top level of git working dir
gitpath=$(git rev-parse --show-toplevel)
dir=${gitpath##*/}

[ -d /tmp/$USER ] || mkdir /tmp/$USER

rsync -a --exclude .git --exclude packages $gitpath /tmp/$USER

if [ $(getenforce) == Enforcing ]; then
    echo "You must do 'sudo setenforce permissive'"
    echo "Otherwise debian fakeroot command doesn't work on shared volumne"
    exit 1
fi

# Assumes docker user in image is armcross, with a $HOME of /home/armcross
# Could get fancy and fetch those values with docker inspect

docker run --rm -v /tmp/$USER/$dir:/home/armcross/$dir:rw,Z -i -t debian-armel-kern-cross:jessie /bin/bash

