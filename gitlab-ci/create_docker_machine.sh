#!/bin/bash
set -ex

# First, authenticate with GCE
# Run the following in terminal and approve in your browser
# gcloud init
# gcloud auth application-default login

# Create GCE instance for Gitlab CI
DOCKER_MACHINE_NAME=gitlab-ci

docker-machine create --driver google \
  --google-project docker-276915 \
  --google-zone europe-west1-b \
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
  --google-machine-type n1-standard-1 \
  --google-disk-size "100" \
  --google-open-port 22/tcp \
  --google-open-port 80/tcp \
  --google-open-port 443/tcp \
  $DOCKER_MACHINE_NAME

# Install Docker-Compose
docker-machine ssh $DOCKER_MACHINE_NAME "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo add-apt-repository \"deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\""
docker-machine ssh $DOCKER_MACHINE_NAME "sudo apt-get update"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo apt-get install -y docker-compose"
docker-machine ssh $DOCKER_MACHINE_NAME "docker-compose --version"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo dockerd"

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

# Add a Gitlab runner
docker-machine ssh $DOCKER_MACHINE_NAME "sudo docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest"

# Register the runner
# docker-machine ssh $DOCKER_MACHINE_NAME
# sudo docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
