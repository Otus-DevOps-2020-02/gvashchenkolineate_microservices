#!/bin/bash

gcloud compute firewall-rules create cadvisor-default --allow tcp:8080
