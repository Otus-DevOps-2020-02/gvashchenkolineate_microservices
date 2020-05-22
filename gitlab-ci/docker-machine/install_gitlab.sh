#!/bin/bash
set -ex

# Create GCE instance for Gitlab CI
DOCKER_MACHINE_NAME=gitlab-ci

# Create necessary directories
docker-machine ssh $DOCKER_MACHINE_NAME "sudo mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo chown -R docker-user:docker-user /srv/gitlab"

# Get ip of gitlab instance
docker-machine ip $DOCKER_MACHINE_NAME

# Create docker-compose file
docker-machine ssh $DOCKER_MACHINE_NAME "cat << EOF > /srv/gitlab/docker-compose.yml
  web:
    image: 'gitlab/gitlab-ce:latest'
    restart: always
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://$(docker-machine ip $DOCKER_MACHINE_NAME)'
    ports:
      - '80:80'
      - '443:443'
      - '2222:22'
    volumes:
      - '/srv/gitlab/config:/etc/gitlab'
      - '/srv/gitlab/logs:/var/log/gitlab'
      - '/srv/gitlab/data:/var/opt/gitlab'
EOF"

# Start Gitlab CI
docker-machine ssh $DOCKER_MACHINE_NAME "cd /srv/gitlab; sudo docker-compose up -d"

# ... Gitlab initialization may take a while ...
# Check it on http://$(docker-machine ip $DOCKER_MACHINE_NAME)
