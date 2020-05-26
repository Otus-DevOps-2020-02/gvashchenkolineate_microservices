#!/bin/bash
set -ex

DOCKER_MACHINE_NAME=gitlab-ci

# Add a Gitlab runner
docker-machine ssh $DOCKER_MACHINE_NAME "sudo docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest"

# Register the runner manually
# docker-machine ssh $DOCKER_MACHINE_NAME
# sudo docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false

# -----------------------------------------------------------------------------------------------------------

# Grab runner registration token from Gitlab
# http://<gitlab_ip>/<group>/<project>/-/settings/ci_cd
PROJECT_REGISTRATION_TOKEN=

# Run and register new runner
# https://docs.gitlab.com/runner/register/#one-line-registration-command
docker-machine ssh $DOCKER_MACHINE_NAME "sudo docker run -d \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest \
  gitlab-runner register --non-interactive \
  --url \"http://$(docker-machine ip $DOCKER_MACHINE_NAME)\" \
  --registration-token \"$PROJECT_REGISTRATION_TOKEN\" \
  --description \"docker-runner\" \
  --tag-list \"linux,xenial,ubuntu,docker\" \
  --executor \"docker\" \
  --docker-image alpine:latest \
  && gitlab-runner run --user=gitlab-runner --working-directory=/home/gitlab-runner"

# !!! NOTE !!!
# The last command fails because `docker run` with 2 commands
# should be wrapped in `docker run ... /bin/bash -c 'command1 ; command2'
# This becomes too complicated. Consider to use Ansible instead.
