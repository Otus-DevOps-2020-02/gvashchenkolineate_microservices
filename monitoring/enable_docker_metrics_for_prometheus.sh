#!/bin/bash
set -ex

#
# Enable collecting Docker metrics with Prometheus.
# Docs: https://docs.docker.com/config/daemon/prometheus/
#
# Although the docs instructs to set 'metrics-addr' to 127.0.0.1
# and then use localhost:9223 for metrics collecting
# the working settings are 'metrics-addr: 0.0.0.0:9323'
# and defining `extra_host` dockerhost=172.17.0.1
# (docker container default interface gateway address) if using docker-compose.
# This way docker metrics are accessible on dockerhost:9323 in Prometheus scrape job.
# To read: https://github.com/docker/docker.github.io/issues/6028#issue-297915571
#

docker-machine ssh docker-host "cat << EOF > /tmp/docker-daemon.json
{
  \"metrics-addr\" : \"0.0.0.0:9323\",
  \"experimental\" : true
}
EOF"

docker-machine ssh docker-host "sudo cp /tmp/docker-daemon.json /etc/docker/daemon.json"

docker-machine ssh docker-host "sudo systemctl restart docker"
