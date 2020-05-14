#!/bin/bash
set -ex

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
