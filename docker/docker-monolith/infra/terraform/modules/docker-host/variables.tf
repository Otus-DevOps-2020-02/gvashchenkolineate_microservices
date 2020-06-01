variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable machine_type {
  description = "Docker host machine type"
  default = "n1-standard-1"
}

variable instance_count {
  description = "Number of instances to create"
  default     = "1"
}

variable docker_disk_image {
  description = "Disk image for docker host"
  default = "docker-host"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable "expose_port_puma" {
  description = "'True' adds firewall rule allowing access for connections on Puma port (9292)"
  default = true
}

variable "expose_port_http" {
  description = "'True' adds firewall rule allowing access for connections on HTTP port (80)"
  default = false
}
