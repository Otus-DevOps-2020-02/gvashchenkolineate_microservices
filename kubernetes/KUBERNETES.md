# How to run Kubernetes in GCP

- Use [Terraform](./terraform) project to create K8s cluster in GKE
  and add firewall rules for nodeports

      cd ./terraform
      terraform init
      terraform apply

- Connect to K8s cluster (grab it from `terraform output`)

      gcloud container clusters get-credentials cluster-2 --zone europe-west1-b --project docker-276915

- Create `dev` namepspace

      kubectl apply -f ./reddit/dev-namespace.yml

- Create K8s resources for reddit app

      kubectl apply -f ./reddit/

- To enable K8s cluster dashboard follow instruction in [DASHBOARD.md](./dashboard/DASHBOARD.md)