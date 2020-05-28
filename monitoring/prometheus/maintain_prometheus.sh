#!/bin/bash
set -ex

# configure local env
eval $(docker-machine env docker-host)

docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus

docker-machine ip docker-host

docker stop prometheus

export USER_NAME=gvashchenko

docker build -t $USER_NAME/prometheus .

# Running `docker/docker-compose up -d` uses `docker/docker-compose.override.yml`
# and when using docker-machine with GCP it may cause a problem of failed reddit-services
# because volumes mounted to containers are not the files on your localhost
# but are supposed to be the files on docker-machine itself.
# Solution: use this command
docker-compose -f docker-compose.yml up -d
