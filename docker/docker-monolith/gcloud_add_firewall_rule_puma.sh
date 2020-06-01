#!/bin/bash

gcloud compute firewall-rules create reddit-app \
 --allow tcp:9292 \
 --target-tags=docker-machine \
 --description="Allow Puma connections" \
 --direction=INGRESS
