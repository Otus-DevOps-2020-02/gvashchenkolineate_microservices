#!/bin/bash
set -ex

echo Kill running containers
docker kill $(docker ps -q)

# ---------------------------------------------------------------- Build basic images

echo Set dockerhub login for next command substitution
DOCKERHUB_LOGIN=gvashchenko
# or in terminal:
# export DOCKERHUB_LOGIN=gvashchenko

echo Build docker images from sources
docker pull mongo:latest
docker build -t $DOCKERHUB_LOGIN/post:1.0 ./post-py
docker build -t $DOCKERHUB_LOGIN/comment:1.0 ./comment
docker build -t $DOCKERHUB_LOGIN/ui:1.0 ./ui

# ---------------------------------------------------------------- Network

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

# ---------------------------------------------------------------- Volumes

echo Create volume for Mongo data
docker volume create reddit_db

echo Run docker containers with created volume
docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post $DOCKERHUB_LOGIN/post:1.0
docker run -d --network=reddit --network-alias=comment $DOCKERHUB_LOGIN/comment:2.0
docker run -d --network=reddit -p 9292:9292 $DOCKERHUB_LOGIN/ui:3.0

# ---------------------------------------------------------------- Network experiments

echo Create a separate bridge-networks
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24

echo Run services in two bridge-networks so that ui has no access to database
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=front_net -p 9292:9292 --name ui  $DOCKERHUB_LOGIN/ui:1.0
docker run -d --network=back_net --name comment  $DOCKERHUB_LOGIN/comment:1.0
docker run -d --network=back_net --name post  $DOCKERHUB_LOGIN/post:1.0

echo Connect post & comment containers to front_net
docker network connect front_net post
docker network connect front_net comment

# ----------------------------------------------------------------- Commands for network investigations

# Watch current net namespaces
sudo ln -s /var/run/docker/netns /var/run/netns
sudo ip netns

# Install bridge-utils
sudo apt-get update && sudo apt-get install bridge-utils
docker network ls
ifconfig | grep br
brctl show <br-interface>
sudo iptables -nL -t nat -v
ps ax | grep docker-proxy
