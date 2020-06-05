#!/bin/bash

gcloud compute firewall-rules create prometheus-blackbox-default --allow tcp:9115
