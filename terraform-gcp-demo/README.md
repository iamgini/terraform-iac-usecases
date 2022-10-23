# GCP Sandbox using Terraform 

This is a simple GCP Instance provisionin script using Terraform. (I use this for quick VM provisioning and do testing using Ansible Playbooks latr; and ofcourse destroy it later)

- Add your SSH Public Key to GCP -> Metadata -> SSH Keys. The new VM will have this automatically and you can directly access the VM using the the ssk key.


- See all [Regions and zones](https://cloud.google.com/compute/docs/regions-zones) Available. (Also see [Global, regional, and zonal resources](https://cloud.google.com/compute/docs/regions-zones/global-regional-zonal-resources))
- [Getting Started with the Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)