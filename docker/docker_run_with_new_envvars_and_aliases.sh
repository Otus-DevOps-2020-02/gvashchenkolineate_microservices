#!/bin/bash
set -ex

echo Set dockerhub login for next command substitution
DOCKERHUB_LOGIN=gvashchenko

echo Kill running containers if any
docker ps -q | xargs --no-run-if-empty docker kill

echo Run docker containers with new network aliases passing them through docker run --env wihtout image rebuild
docker run -d --network=reddit \
  --network-alias=post_db_new \
  --network-alias=comment_db_new \
  mongo:latest

docker run -d --network=reddit \
  --network-alias=post_new \
  --env POST_DATABASE_HOST=post_db_new \
  $DOCKERHUB_LOGIN/post:1.0

docker run -d --network=reddit \
  --network-alias=comment_new \
  --env COMMENT_DATABASE_HOST=comment_db_new \
  $DOCKERHUB_LOGIN/comment:1.0

docker run -d --network=reddit \
  -p 9292:9292 \
  --env POST_SERVICE_HOST=post_new \
  --env COMMENT_SERVICE_HOST=comment_new \
  $DOCKERHUB_LOGIN/ui:1.0
