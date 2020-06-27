# How to run Kubernetes in GCP

_Requires Google provider v3.0.0+ for Terraform!_

- Use [Terraform](./terraform) project to create K8s cluster in GKE
  and add firewall rules for nodeports

      cd ./terraform
      terraform init
      terraform apply

- Connect to K8s cluster (grab it from `terraform output`)

      gcloud container clusters get-credentials cluster-2 --zone europe-west1-b --project docker-276915

- Create `dev` namepspace

      kubectl apply -f ./reddit/dev-namespace.yml

- Create K8s resources for reddit app in `dev` namespace

      kubectl apply -f ./reddit/ -n dev

- To enable K8s cluster dashboard follow instruction in [DASHBOARD.md](./dashboard/DASHBOARD.md)
