output "kubernetes-cluster-connection" {
  value = join("", [
    "gcloud container clusters get-credentials ",
    google_container_cluster.kubernetes-cluster.name,
    " --zone ", var.zone,
    " --project ", var.project
  ])
}
