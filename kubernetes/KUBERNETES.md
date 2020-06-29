# How to run Kubernetes in GCP

_Requires Google provider v3.0.0+ for Terraform!_

- Use [Terraform](./terraform) project to create K8s cluster in GKE
  and add firewall rules for nodeports

      cd ./terraform
      terraform init
      terraform apply

- Connect to K8s cluster (grab it from `terraform output`)

      gcloud container clusters get-credentials cluster-1 --zone europe-west1-b --project docker-276915

- Enable GKE **Network-policy** (Already implemented in terraform project)
  _Can take a long time!_

       gcloud beta container clusters update cluster-1 --zone=europe-west1-b --update-addons=NetworkPolicy=ENABLED
       gcloud beta container clusters update cluster-1 --zone=europe-west1-b --enable-network-policy

- Create `dev` namepspace

      kubectl apply -f ./reddit/dev-namespace.yml

- Create K8s resources for reddit app in `dev` namespace

      kubectl apply -f ./reddit/ -n dev

- TLS termination

  - Create a TLS certificate for `ui` Ingress

        export INGRESS_IP=$(kubectl get ingress ui -n dev -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=$INGRESS_IP"

  - and upload the certificate to the K8s cluster

        kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev

  - or pass the tsl certificate and key into the yaml-manifest
    [ui-tls-secret.yml](./reddit/ui-tls-secret.yml) this way:

        data:
          tls.crt: cat ./tls.crt | base64
          tls.key: cat ./tls.key | base64

- To enable K8s cluster dashboard follow instruction in [DASHBOARD.md](./dashboard/DASHBOARD.md)
