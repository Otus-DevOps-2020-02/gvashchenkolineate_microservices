variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable cluster_name {
  description = "Cluster name"
  default     = "cluster-1"
}

variable node_count {
  description = "Number of cluster nodes"
  default     = "2"
}

variable node_disk_size_gb {
  description = "Node disk size"
  default     = "100"
}

variable machine_type {
  description = "Node machine type"
  default     = "n1-standard-1"
}

variable storage_size {
  description = "Size of the persistent disk for Mongodb, in GB"
  default     = 25
}

variable legacy_authorization {
  description = "Enable legacy authorization specially for Gitlab installation"
  default     = false
}

variable logging_service {
  description = "The logging service that the cluster should write logs to"
  default = "logging.googleapis.com/kubernetes"
}

variable monitoring_service {
  description = "The monitoring service that the cluster should write metrics to"
  default = "monitoring.googleapis.com/kubernetes"
}

variable oauth_scopes {
  type = list(string)
  description = "List of oauth scopes for cluster"
  default = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/trace.append"
  ]
}
