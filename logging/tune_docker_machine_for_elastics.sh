#!/bin/bash
set -ex

# Elasticsearch start issue: vm.max_map_count [65530] is too low, increase to at least [262144]
# https://www.elastic.co/guide/en/elasticsearch/reference/7.4/docker.html#_set_vm_max_map_count_to_at_least_262144

docker-machine ssh logging "sudo sysctl -w vm.max_map_count=262144"
