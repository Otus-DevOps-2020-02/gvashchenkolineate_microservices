#!/bin/bash
set -ex

echo Kill running containers
docker kill $(docker ps -q)

echo Set dockerhub login for next command substitution
DOCKERHUB_LOGIN=gvashchenko

echo Build docker images from sources
docker pull mongo:latest
docker build -t $DOCKERHUB_LOGIN/post:1.0 ./post-py
docker build -t $DOCKERHUB_LOGIN/comment:1.0 ./comment
docker build -t $DOCKERHUB_LOGIN/ui:1.0 ./ui

echo Create docker network for the app
docker network create reddit

echo Run docker containers
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post $DOCKERHUB_LOGIN/post:1.0
docker run -d --network=reddit --network-alias=comment $DOCKERHUB_LOGIN/comment:1.0
docker run -d --network=reddit -p 9292:9292 $DOCKERHUB_LOGIN/ui:1.0

# --------------------------------------------------------------- Image minization

echo Build optimized ui image from ubuntu
docker build -t $DOCKERHUB_LOGIN/ui:2.0 ./ui

echo Build optimized ui image from alpine
docker build -t $DOCKERHUB_LOGIN/ui:3.0 -f ./ui/Dockerfile.3 ./ui

echo Build optimized comment image from alpine
docker build -t $DOCKERHUB_LOGIN/comment:2.0 ./comment

# Image diff
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep gvashchenko | sort
#  gvashchenko/comment     1.0    752MB
#  gvashchenko/comment     2.0    243MB
#  gvashchenko/post        1.0    110MB
#  gvashchenko/ui          1.0    786MB
#  gvashchenko/ui          2.0    462MB
#  gvashchenko/ui          3.0    246MB

# --------------------------------------------------------------- Run minimized images

echo Run docker containers from minimized images
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post $DOCKERHUB_LOGIN/post:1.0
docker run -d --network=reddit --network-alias=comment $DOCKERHUB_LOGIN/comment:2.0
docker run -d --network=reddit -p 9292:9292 $DOCKERHUB_LOGIN/ui:3.0
