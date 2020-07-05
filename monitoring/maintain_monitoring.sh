#!/bin/bash
set -ex

# configure local env
eval $(docker-machine env docker-host)

docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus

docker-machine ip docker-host

docker stop prometheus

export USER_NAME=gvashchenko

# Build all own images
cd .. && make b_all

# Build own image
docker build -t $USER_NAME/prometheus ./prometheus
docker build -t $USER_NAME/blackbox-exporter ./blackbox-exporter
docker build -t $USER_NAME/cloudprober ./cloudprober

# Build all service images
for i in ui post comment; do cd src/$i; bash docker_build.sh; cd -; done


# Running `docker/docker-compose up -d` uses `docker/docker-compose.override.yml`
# and when using docker-machine with GCP it may cause a problem of failed reddit-services
# because volumes mounted to containers are not the files on your localhost
# but are supposed to be the files on docker-machine itself.
# Solution: use this command
docker-compose -f docker-compose.yml up -d

# Run docker-compose for monitoring services
docker-compose -f docker-compose-monitoring.yml up -d

# Or a one-liner:
for i in docker-compose.yml docker-compose-monitoring.yml; do docker-compose -f $i up -d; done

# Check containers are running
docker-compose -f docker-compose.yml ps
docker-compose -f docker-compose-monitoring.yml ps
# Or a one-liner
for i in docker-compose.yml docker-compose-monitoring.yml; do docker-compose -f $i ps; done


# Cease down a service and bring it up again
docker-compose stop post
docker-compose start post

# Push images to dockerhub
docker login
for i in ui comment post prometheus blackbox-exporter cloudprober; do docker push $USER_NAME/$i; done
