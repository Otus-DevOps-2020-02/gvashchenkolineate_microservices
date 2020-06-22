#!/bin/bash

gcloud compute firewall-rules create kubernetes-nodeports-default --allow tcp:30000-32767
