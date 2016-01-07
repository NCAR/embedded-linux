#!/bin/sh

# Run bash in debian-armel-cross:jessie image, copying portions of this git working
# directory to /tmp/$USER and sharing it as a docker volume in the docker user's home
# directory

# top level of git working dir
gitpath=$(git rev-parse --show-toplevel)
dir=${gitpath##*/}

[ -d /tmp/$USER ] || mkdir /tmp/$USER

rsync -a --exclude .git --exclude linux-stable --exclude packages $gitpath /tmp/$USER

# Assumes docker user in image is armcross, with a $HOME of /home/armcross
# Could get fancy and fetch those values with docker inspect

docker run --rm -v /tmp/$USER/$dir:/home/armcross/$dir:rw,Z -i -t debian-armel-cross:jessie /bin/bash

