#!/bin/bash

gcloud compute firewall-rules create alertmanager-default --allow tcp:9093
