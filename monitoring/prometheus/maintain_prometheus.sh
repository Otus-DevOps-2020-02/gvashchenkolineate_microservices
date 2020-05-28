#!/bin/bash
set -ex

# configure local env
eval $(docker-machine env docker-host)

docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus

docker-machine ip docker-host

docker stop prometheus

export USER_NAME=gvashchenko

docker build -t $USER_NAME/prometheus .
