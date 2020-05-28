#!/bin/bash
set -ex

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

# Check the machine created and its public IP
docker-machine ls

# Don't forget to add GCP firewall rules, e.g. to allow Puma connections on port 9292.
# Use gcloud_add_firewall_rule_puma.sh

# Connect to the machine
docker-machine ssh docker-host
