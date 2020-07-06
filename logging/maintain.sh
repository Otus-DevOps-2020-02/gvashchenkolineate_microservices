#!/bin/bash
set -ex

# configure local env
eval $(docker-machine env docker-host)

export USER_NAME=gvashchenko

# Build all reddit app components images
for i in ui post comment; do cd src/$i; bash docker_build.sh; docker push $USER_NAME/$i; cd -; done

cd docker

# Run or create and run all app services and logging services
docker-compose -f docker-compose.yml -f docker-compose-logging.yml up -d

# Check containers are running
docker-compose -f docker-compose.yml -f docker-compose-logging.yml ps
