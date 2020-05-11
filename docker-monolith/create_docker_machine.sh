#!/bin/bash

# First, authenticate with GCE
# Run the following in terminal and approve in your browser
# gcloud init
# gcloud auth application-default login

export GOOGLE_PROJECT=docker-276915

docker-machine create --driver google \
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
  --google-machine-type n1-standard-1 \
  --google-zone europe-west1-b \
  docker-host

# Switch to use created machine
eval $(docker-machine env docker-host)

# Build the app image
docker build -t reddit:latest .

# List all itermadiate docker images created:
docker images -a

# Run the app container from created image
docker run --name reddit -d --network=host reddit:latest

# Check the machine created and its public IP
docker-machine ls

# Now, one can surf to http:<IP>:9292 to check the app is working
# Don't forget to add GCP firewall rule to allow Puma connections on port 9292.
# Use gcloud_add_firewall_rule_puma.sh
