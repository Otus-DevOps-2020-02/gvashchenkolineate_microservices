#!/bin/bash
set -ex

export GOOGLE_PROJECT=docker-276915

# create docker host
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    # TODO should create an instance without this explicitly set scope to copy default scopes here because it overrides all others
    --google-scopes "https://www.googleapis.com/auth/monitoring.read"\
    docker-host
