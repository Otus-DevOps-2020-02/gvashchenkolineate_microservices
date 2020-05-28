locals {
  instance_tag = "docker-host"
}
//---------------------------------------------------------------------- instance app
resource "google_compute_instance" "docker" {
  count = var.instance_count
  name         = "docker-host-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = var.docker_disk_image
    }
  }
  tags = [local.instance_tag]
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.app_ip[count.index].address
    }
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}
//---------------------------------------------------------------------- IP Address
resource "google_compute_address" "app_ip" {
  count = var.instance_count
  name = "docker-host-ip-${count.index}"
}
//---------------------------------------------------------------------- firewall rule puma
resource "google_compute_firewall" "firewall_puma" {
  count = var.expose_port_puma ? 1 : 0
  name = "docker-host-allow-puma"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = [local.instance_tag]
}
//---------------------------------------------------------------------- firewall rule http
resource "google_compute_firewall" "firewall_http" {
  count = var.expose_port_http ? 1 : 0
  name = "docker-host-allow-http"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = [local.instance_tag]
}
