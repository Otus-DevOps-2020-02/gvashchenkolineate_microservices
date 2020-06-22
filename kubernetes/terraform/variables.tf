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
