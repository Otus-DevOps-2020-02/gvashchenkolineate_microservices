#!/bin/bash

gcloud compute firewall-rules create prometheus-cloudprober --allow tcp:9313
