#!/bin/bash
set -ex

DOCKER_MACHINE_NAME=gitlab-ci

# Install Docker-Compose
docker-machine ssh $DOCKER_MACHINE_NAME "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo add-apt-repository \"deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\""
docker-machine ssh $DOCKER_MACHINE_NAME "sudo apt-get update"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo apt-get install -y docker-compose"
docker-machine ssh $DOCKER_MACHINE_NAME "docker-compose --version"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo dockerd"
