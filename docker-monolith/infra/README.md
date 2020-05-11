# Infra Project prototype

### Content

 - Packer
   Template of an instance with pre-installed Docker

   ```
   packer build -var-file ./packer/variables.json ./packer/docker-host.json
   ```

 - Terraform
   Project to bring up specified number of app instances in GCP

 - Ansible
   Playbooks for installing Docker and starting app image
   using dynamic inventory
