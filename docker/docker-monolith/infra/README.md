# Infra Project prototype

### Content

 - Packer
   Template of image creation of an instance with pre-installed Docker

   ```
   packer build -var-file ./packer/variables.json ./packer/docker-host.json
   ```

 - Terraform
   Project to bring up specified number of app instances in GCP

   ```
   cd ./terraform
   terraform init
   terraform apply
   ```

 - Ansible
   Playbooks for installing Docker and starting app image
   using dynamic inventory

   ```
   # First, create GCP service account with 'Compute Admin' and 'Service Account User' roles,
   # download json-key and rename it to './ansible/credentials.json'

   cd ./ansible
   ansible-playbook ./playbooks/site.yml --check
   ansible-playbook ./playbooks/site.yml
   ```
