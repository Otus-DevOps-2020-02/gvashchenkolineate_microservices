#!/bin/bash
set -ex

DOCKER_MACHINE_NAME=gitlab-ci

# Add a Gitlab runner
docker-machine ssh $DOCKER_MACHINE_NAME "sudo docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest"

# Register the runner
# docker-machine ssh $DOCKER_MACHINE_NAME
# sudo docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
