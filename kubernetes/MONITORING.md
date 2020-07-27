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

#### Prometheus

Pull Prometheus Helm-chart and give it [custom-values.yaml](./Charts/prometheus/custom_values.yml)

    cd kubernetes/Charts && helm fetch --untar stable/prometheus

Start Prometheus in k8s

    cd kubernetes/Charts/prometheus
    helm upgrade prom . -f custom_values.yaml --install

cAdvisor metrics prefix: `container_` (in Prometheus UI, Graph pane)

##### Kube state metrics

Enable **kube-state-metrics** in [custom-values.yaml](./Charts/prometheus/custom_values.yml)

    kubeStateMetrics:
        enabled: true

Update release

    helm upgrade prom . -f custom_values.yaml --install

Metrics prefix: `kube_`

##### NodeExporter metrics

Enable **node-exporter** in [custom-values.yaml](./Charts/prometheus/custom_values.yml)

    nodeExporter:
        enabled: false

Update release

    helm upgrade prom . -f custom_values.yaml --install

Metrics prefix: `node_`

#### Reddit application

Start the app

    helm upgrade reddit-test ./reddit --install
    helm upgrade staging --namespace staging ./reddit --install
    helm upgrade production --namespace production ./reddit --install

Add Prometheus job to [custom-values.yaml](./Charts/prometheus/custom_values.yml)

    scrape_configs:
      - job_name: 'reddit-production'
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_service_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            target_label: kubernetes_namespace
          - source_labels: [__meta_kubernetes_service_name]
            target_label: kubernetes_name
          - source_labels: [__meta_kubernetes_service_label_app, __meta_kubernetes_namespace]
            action: keep
            regex: reddit;(production|staging)+

      # <component> is of ui, post and comment
      - job_name: '<component>-endpoints'
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_service_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            target_label: kubernetes_namespace
          - source_labels: [__meta_kubernetes_service_name]
            target_label: kubernetes_name
          - source_labels: [__meta_kubernetes_service_label_component]
            action: keep
            regex: <component>

#### Grafana

Install Grafana

    helm upgrade --install grafana stable/grafana \
        --set "adminPassword=admin" \
        --set "service.type=NodePort" \
        --set "ingress.enabled=true" \
        --set "ingress.hosts={reddit-grafana}"

Add Prometheus service name as Grafana DataSource, e.g. `prom-prometheus-server`.
Get the name from:

      kubectl get svc

Configrue Grafana dashboards
