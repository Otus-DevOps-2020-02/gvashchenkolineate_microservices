FROM grafana/grafana:5.0.0

COPY datasources.yml /etc/grafana/provisioning/datasources/
COPY dashboard_providers.yml /etc/grafana/provisioning/dashboards/
COPY dashboards/* /var/lib/grafana/dashboards/
