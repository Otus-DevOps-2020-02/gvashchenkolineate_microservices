# Kubernetes. Monitoring

#### Prerequisites

Helm v2.16.9 expected to be used in commands below.

##### Nginx

Install Nginx

    helm install stable/nginx-ingress --name nginx

Check nginx IP

    kubectl get svc

and add it to `/etc/hosts` as

    <IP> reddit reddit-prometheus reddit-grafana reddit-non-prod production redditkibana staging prod

#### EFK stack

Install Elasticsearch and Fluentd

    helm install --name efk ./Charts/efk

Install Kibana

    helm upgrade --install kibana stable/kibana \
        --set "ingress.enabled=true" \
        --set "ingress.hosts={reddit-kibana}" \
        --set "env.ELASTICSEARCH_URL=http://efk-efk-elasticsearch-logging:9200" \
        --version 0.1.1

##### Kibana

Add an index pattern `fluentd-*`
