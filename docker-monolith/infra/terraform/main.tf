//---------------------------------------------------------------------- terraform / backend
terraform {
  required_version = "~>0.12.0"
}
//---------------------------------------------------------------------- provider
provider "google" {
  version = "~>2.5.0"
  project = var.project
  region  = var.region
}
//---------------------------------------------------------------------- docker hosts
module docker-host {
  source            = "./modules/docker-host"
  zone              = var.zone
  instance_count    = var.instance_count
  machine_type      = var.machine_type
  docker_disk_image = var.docker_disk_image
  public_key_path   = var.public_key_path
  private_key_path  = var.private_key_path
  expose_port_puma  = var.expose_port_puma
  expose_port_http  = var.expose_port_http
}
