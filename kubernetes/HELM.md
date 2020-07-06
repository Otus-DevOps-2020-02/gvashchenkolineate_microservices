# Helm

It's supposed that kubernetes cluster is already up and running,
Kubectl context is switch to it, but no deployments are applied against it.

     cd ./Charts

#### Tiller

Install Tiller - Helm server side:

     kubectl apply -f tiller.yml

Start Tiller server:

     helm init --service-account tiller

Check it's up and running:

     kubectl get pods -n kube-system --selector app=helm

#### Helm2/3 Tiller plugin

Optional.
To get rid of insecure using Tiller with cluster-admin rights.

Delete existed Tiller from K8s cluster without deleting releases

     helm reset --force


##### Helm2

Install the plugin

     helm init --client-only
     helm plugin install https://github.com/rimusz/helm-tiller
     helm tiller run -- helm upgrade --install --wait --namespace=reddit-ns reddit reddit/

##### Helm3

     curl https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz -o helm-v3.2.4-linux-amd64.tar.gz
     tar -zxvf helm-v3.2.4-linux-amd64.tar.gz
     mv linux-amd64/helm /usr/local/bin/helm3
     kubectl create ns new-helm
     helm3 upgrade --install --namespace=new-helm --wait reddit-release reddit/

#### Charts

Install ui chart

     helm install --name test-ui-1 ui/

Check

     helm ls

Upgrate chart

     helm upgrade test-ui-1 ui/
     helm upgrade <release-name> ./reddit

Delete chart and it's name from release history

     helm del --purge test-ui-1

Search for opensource chart as a dependency, e.g. mongo

     helm search mongo

Update char dependencies

     helm dep update
     helm dep update ./reddit

Install Reddit application chart with dependencies

     helm install reddit --name reddit-test

#### Gitlab

Add Helm repository

     helm repo add gitlab https://charts.gitlab.io

Download **gitlab** chart to edit

     helm fetch gitlab/gitlab-omnibus --version 0.1.37 --untar

Tune gitlab chart setting `baseDomain`

Install Gitlab

     helm install --name gitlab . -f values.yaml

Find gitlab ingress IP address

     kubectl get service -n nginx-ingress nginx
     GITLAB_IP=$(kubectl get service -n nginx-ingress nginx -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

Add gitlab ingress IP to `/etc/hosts`

     echo "$GITLAB_IP gitlab-gitlab production" >> /etc/hosts
