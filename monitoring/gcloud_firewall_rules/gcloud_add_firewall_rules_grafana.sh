#!/bin/bash

gcloud compute firewall-rules create grafana-default --allow tcp:3000
