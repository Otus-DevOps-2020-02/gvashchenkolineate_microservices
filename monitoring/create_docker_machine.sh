#!/bin/bash
set -ex

export GOOGLE_PROJECT=docker-276915

# Default access scopes
# --google-scopes "https://www.googleapis.com/auth/devstorage.read_only,
#   https://www.googleapis.com/auth/logging.write,
#   https://www.googleapis.com/auth/monitoring.write"

# Access scope especially for Stackdriver monitoring
# --google-scopes "https://www.googleapis.com/auth/monitoring.read"

# create docker host
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    --google-scopes "https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring" \
    docker-host
