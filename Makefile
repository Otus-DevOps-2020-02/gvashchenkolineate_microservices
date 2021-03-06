###############################################
## One can change docker hub login with
## `make user="<login>" ...`
###############################################
user ?= gvashchenko
export USER_NAME=$(user)

###############################################
## Build images from sources
## and push them to docker hub
###############################################
default: b_all p_all

###############################################
## Build images
###############################################
b_all: b_src b_monitoring b_logging

b_src: b_ui b_comment b_post

b_monitoring: b_prometheus b_blackbox-exporter b_cloudprober b_alertmanager b_grafana

b_logging: b_fluentd

# ---------------------------------------------- src
b_ui:
	@echo  Build docker image for: ui
	docker build -t $(user)/ui ./src/ui/

b_comment:
	@echo  Build docker image for: comment
	docker build -t $(user)/comment ./src/comment/

b_post:
	@echo  Build docker image for: post
	docker build -t $(user)/post ./src/post/

# ---------------------------------------------- monitoring
b_prometheus:
	@echo  Build docker image for: prometheus
	docker build -t $(user)/prometheus ./monitoring/prometheus

b_blackbox-exporter:
	@echo  Build docker image for: blackbox-exporter
	docker build -t $(user)/blackbox-exporter ./monitoring/blackbox-exporter

b_cloudprober:
	@echo  Build docker image for: cloudprober
	docker build -t $(user)/cloudprober ./monitoring/cloudprober

b_alertmanager:
	@echo  Build docker image for: alertmanager
	docker build -t $(user)/alertmanager ./monitoring/alertmanager

b_telegraf:
	@echo  Build docker image for: telegraf
	docker build -t $(user)/telegraf ./monitoring/telegraf

b_grafana:
	@echo  Build docker image for: grafana
	docker build -t $(user)/grafana ./monitoring/grafana

# ---------------------------------------------- logging
b_fluentd:
	@echo  Build docker image for: fluentd
	docker build -t $(user)/fluentd ./logging/fluentd

###############################################
## Push images to docker hub
###############################################

p_all: p_src p_monitoring p_logging

p_src: p_ui p_comment p_post

p_monitoring: p_prometheus p_blackbox-exporter p_cloudprober p_alertmanager p_telegraf p_grafana

p_logging: p_fluentd

# ---------------------------------------------- src
p_ui:
	@echo  Push docker image of: ui
	docker push $(user)/ui

p_comment:
	@echo  Push docker image of: comment
	docker push $(user)/comment

p_post:
	@echo  Push docker image of: post
	docker push $(user)/post

# ---------------------------------------------- monitoring
p_prometheus:
	@echo  Push docker image of: prometheus
	docker push $(user)/prometheus

p_blackbox-exporter:
	@echo  Push docker image of: blackbox-exporter
	docker push $(user)/blackbox-exporter

p_cloudprober:
	@echo  Push docker image of: cloudprober
	docker push $(user)/cloudprober

p_alertmanager:
	@echo  Push docker image of: alermanager
	docker push $(user)/alertmanager

p_telegraf:
	@echo  Push docker image of: telegraf
	docker push $(user)/telegraf

p_grafana:
	@echo  Push docker image of: grafana
	docker push $(user)/grafana

# ---------------------------------------------- logging
p_fluentd:
	@echo  Push docker image of: fluentd
	docker push $(user)/fluentd
