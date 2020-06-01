#!/bin/bash
set -ex

# First, create a docker-machine and connect to it
# Use create_docker_machine.sh

# Build the app image
docker build -t reddit:latest .

# List all itermadiate docker images created:
docker images -a

# Run the app container from created image
docker run --name reddit -d --network=host reddit:latest

# Or run app container from docker hub image
# docker run --name reddit -d -p 9292:9292 gvashchenko/otus-reddit:1.0

# Check the machine created and its public IP
docker-machine ls

# Now, one can surf to http:<IP>:9292 to check the app is working
# Don't forget to add GCP firewall rule to allow Puma connections on port 9292.
# Use gcloud_add_firewall_rule_puma.sh
