//---------------------------------------------------------------------- terraform / backend
terraform {
  required_version = "~>0.12.0"
}
//---------------------------------------------------------------------- provider
provider "google" {
  version = "~>3.0.0"
  project = var.project
  region  = var.region
}
//---------------------------------------------------------------------- firewall rules for kubernetes nodeports
resource "google_compute_firewall" "kubernetes-nodeports" {
  name    = "kubernetes-nodeports-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }
}
//---------------------------------------------------------------------- kubernetes cluster
resource "google_container_cluster" "kubernetes-cluster" {
  name               = "cluster-2"
  location           = var.zone != "" ? var.zone : var.region
  network            = "default"
  initial_node_count = var.node_count

  master_auth {
    //// Basic authentication is disabled
    // username = ""
    // password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.node_disk_size_gb

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled = true
    provider = "CALICO"
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
}
