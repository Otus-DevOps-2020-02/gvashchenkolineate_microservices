#!/bin/bash

gcloud compute firewall-rules create elasticsearch-default --allow tcp:9200
gcloud compute firewall-rules create kibana-default --allow tcp:5601
