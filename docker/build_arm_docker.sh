#!/bin/sh

# Build a docker image of Debian Jessie for doing C/C++ debian builds for
# various targets, such as armel and armhf (RPi).
# The image is built from the Dockerfile.cross_arm in this directory.

# debian-armel-cross:jessie image will have a "builder" user.
# If the eol group exists, the builder user will have that
# numeric group id, otherwise the same group and gid as the user
# that runs this script.

# look for gid of group "eol"
group=eol
gid=$(getent group $group | cut -d: -f3)

# if not found, use user'd gid
if ! [ $eolgid ]; then
    gid=$(id -g)
    group=$(id -g -n)
fi

image=debian-armel-cross:jessie 
arch=armel
docker build -t $image \
    --build-arg=group=$group --build-arg=gid=$gid \
    --build-arg=hostarch=$arch \
    -f Dockerfile.cross_arm .
docker tag  $image maclean/$image
docker push maclean/$image

image=debian-armhf-cross:jessie 
arch=armhf
docker build -t $image \
    --build-arg=group=$group --build-arg=gid=$gid \
    --build-arg=hostarch=$arch \
    -f Dockerfile.cross_arm .
docker tag  $image maclean/$image
docker push maclean/$image
