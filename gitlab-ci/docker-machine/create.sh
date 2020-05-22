#!/bin/bash
set -ex

# First, authenticate with GCE
# Run the following in terminal and approve in your browser
# gcloud init
# gcloud auth application-default login

DOCKER_MACHINE_NAME=gitlab-ci

# Create GCE instance for Gitlab CI
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
