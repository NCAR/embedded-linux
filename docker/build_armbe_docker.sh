#!/bin/sh

set -e

image=fedora25-armbe-cross:ael
docker build --volume=$PWD:/tmp/docker-files:ro,Z -t $image \
    -f Dockerfile.cross_ael_armeb .

docker tag $image maclean/$image
docker push maclean/$image
