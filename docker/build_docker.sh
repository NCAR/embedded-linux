#!/bin/sh

# Build a docker image of Debian Jessie for doing C/C++ cross builds for armel targets.
# The image is built from the Dockerfile in this directory.

# debian-armel-cross:jessie image will have an "armcross" user belonging
# to the same group and gid as the user that runs this script.

docker build -t debian-armel-cross:jessie \
    --build-arg=group=$(id -g -n) --build-arg=gid=$(id -g) \
    $PWD
