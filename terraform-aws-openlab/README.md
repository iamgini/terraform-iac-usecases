# AWS Ansible Automation Platform (AAP) Infrastructure

Terraform configuration for deploying Ansible Automation Platform infrastructure on AWS with high availability, load balancing, and secure bastion access.

## Introduction

This Terraform configuration provisions a complete AAP infrastructure with:

- **9 AAP Nodes** (configurable):
  - 2x Automation Controllers
  - 2x Automation Gateways
  - 2x Automation Hubs
  - 2x Event-Driven Ansible (EDA) Controllers
  - 1x Database Server
- **VPC with Public/Private Subnets** across 2 Availability Zones
- **EFS Storage** for shared AAP Hub content
- **Bastion/Jumpserver** with Elastic IP for secure SSH access
- **Private AAP Nodes** (no public IPs, accessible only via bastion)
- **Nginx Load Balancer** on jumpserver with Let's Encrypt SSL
- **Optional Cloudflare DNS** automation
- Default `region = "ap-southeast-2"` (**Asia Pacific (Sydney)**)

## Prerequisites

1. **Terraform** - [Install](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. **AWS Credentials** - [Configure AWS CLI](https://github.com/iamgini/vagrant-iac-usecases#aws-setup)
3. **Cloudflare DNS** (optional, for custom domain) - See [CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md)
4. **SSH Keys** - Generate if needed:
   ```bash
   ssh-keygen  # Default: ~/.ssh/id_rsa
   ```

## Quick Start

### Step 1. Create SSH Keys to Access the ec2 instances

If you have existing keys, you can use that; otherwise create new ssh keys.

- ***Warning**: Please remember to not to overwrite the existing ssh key pair files; use a new file name if you want to keep the old keys.*

- If you are using any key files other than `~/.ssh/id_rsa`, then remember to update the same in `variables.tf` as well.

```shell
$ ssh-keygen
```

## Step 4. Clone the Repository and create your Ansible Lab

```shell
$ git clone https://github.com/iamgini/terraform-iac-usecases
$ cd terraform-aws-openlab

## init terraform
$ terraform init

## verify the resource details before apply
$ terraform plan

## Apply configuration - This step will spin up all necessary resources in your AWS Account
$ terraform apply
.
.
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.ec2loginkey: Creating...
aws_security_group.ansible_access: Creating...
.
.
Apply complete! Resources: 46 added, 0 changed, 0 destroyed.

Outputs:

aap_ec2_instances = {
  "i-xxx" = {
    "name" = "aap-ac1"
    "private_ip" = "10.0.x.x"
    "public_ip" = ""
  }
  ...
}
jumpserver_public_ip = "<ELASTIC_IP>"
```

## Step 5. Generate AAP Inventory

Get auto-generated inventory for your AAP installer:

```shell
# Get the complete inventory format
terraform output -raw aap_inventory

# Save to file
terraform output -raw aap_inventory > inventory-hosts.txt
```

**Output format** (matches AAP 2.6+ containerized installer):

```ini
# This section is for your AAP Gateway host(s)
# -----------------------------------------------------
[automationgateway]
aap-gw1.example.org ansible_host=10.0.12.185
aap-gw2.example.org ansible_host=10.0.3.62

# This section is for your AAP Controller host(s)
# -----------------------------------------------------
[automationcontroller]
aap-ac1.example.org ansible_host=10.0.13.69
aap-ac2.example.org ansible_host=10.0.6.14

# This section is for your AAP Automation Hub host(s)
# -----------------------------------------------------
[automationhub]
aap-hub1.example.org ansible_host=10.0.6.101
aap-hub2.example.org ansible_host=10.0.12.203

# This section is for your AAP EDA Controller host(s)
# -----------------------------------------------------
[automationeda]
aap-eda1.example.org ansible_host=10.0.2.59
aap-eda2.example.org ansible_host=10.0.14.152

[redis]
aap-gw1.example.org ansible_host=10.0.12.185
aap-gw2.example.org ansible_host=10.0.3.62
aap-hub1.example.org ansible_host=10.0.6.101
aap-hub2.example.org ansible_host=10.0.12.203
aap-eda1.example.org ansible_host=10.0.2.59
aap-eda2.example.org ansible_host=10.0.14.152

[database]
aap-db1.example.org ansible_host=10.0.6.125

# Add to [all:vars]:
# ansible_user=ec2-user
# ansible_ssh_private_key_file=~/.ssh/id_rsa
# ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -i ~/.ssh/id_rsa ec2-user@<JUMPSERVER_IP>" -o StrictHostKeyChecking=no'
```

**Usage:**
1. Copy the output into your AAP inventory file
2. Add your AAP-specific variables (admin passwords, registry credentials, etc.)
3. Run AAP installer from your local machine - it will proxy through bastion automatically!

## Step 6. Setup Nginx Load Balancer (HTTPS)

First, generate the inventory file:

```bash
# Generate inventory from Terraform output
terraform output -raw aap_inventory > inventory.ini
```

Then configure nginx on jumpserver with Let's Encrypt SSL:

```bash
cd playbooks
ansible-playbook -i ../inventory.ini setup-nginx-lb.yml
```

**What this does:**
- Installs nginx on jumpserver
- Configures load balancing to AAP gateway nodes
- Auto-obtains Let's Encrypt SSL certificate
- Sets up HTTPS with auto-renewal

**Access AAP:**
- URL: `https://aap.lab.gineesh.com` (after AAP installation)

## Step 7. SSH Access

**Connect to Bastion:**
```shell
# Get the jumpserver IP from terraform output
terraform output jumpserver_public_ip

# Connect
ssh -i ~/.ssh/id_rsa ec2-user@<JUMPSERVER_IP>
```

**Connect to AAP nodes via Bastion (from local machine):**

The inventory already includes the bastion proxy configuration. When you run the AAP installer from your local machine, it automatically connects through the bastion to reach the private AAP nodes.

**Manual SSH to AAP nodes (for troubleshooting):**
```shell
# Via ProxyCommand (replace IPs with your actual values from terraform output)
ssh -i ~/.ssh/id_rsa -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/id_rsa ec2-user@<JUMPSERVER_IP>" ec2-user@<AAP_NODE_PRIVATE_IP>
```
```

## Configuration Options

### Adjust AAP Node Count

Default: 9 nodes. Modify in `variables.tf`:

```hcl
variable "aap_node_count" {
  default = 9  # Change to 2-10
}
```

### Instance Types

- **AAP Nodes**: `t2.xlarge` (default) - modify in `aap/variables.tf`
- **Bastion**: `t2.micro` (default) - modify in `variables.tf`

### Optional: Cloudflare SSL/TLS Automation

Create `terraform.tfvars` for automatic SSL certificate via Cloudflare:

```hcl
cloudflare_api_token = "YOUR_CLOUDFLARE_API_TOKEN"
cloudflare_zone_id   = "YOUR_ZONE_ID"
aap_domain_name      = "aap.yourdomain.com"
```

### Apply Modules Independently

This configuration includes two separate AAP deployment modules:
- **`aap`** - Multi-node HA cluster (9 nodes)
- **`aapaio`** - All-in-One single instance (c5.4xlarge)

You can apply them independently without affecting each other:

#### Apply only the AAP All-in-One (aapaio) module:

```bash
# Plan only aapaio resources
terraform plan -target=module.aapaio

# Apply only aapaio resources
terraform apply -target=module.aapaio

# Include Cloudflare DNS for aapaio
terraform apply -target=module.aapaio -target=cloudflare_record.aapaio
```

#### Apply only the multi-node AAP cluster:

```bash
# Apply only the aap module
terraform apply -target=module.aap

# Include related resources (jumpserver, Cloudflare DNS)
terraform apply -target=module.aap -target=aws_instance.jumpserver -target=cloudflare_record.aap
```

#### Alternative: Comment out modules in main.tf

Instead of using `-target` flags, you can temporarily comment out modules you don't want to apply:

```hcl
# Comment the below one if not required
# module "aap" {
#   source = "./aap"
#   ...
# }
```

Then run normal `terraform apply`.

**Notes:**
- Both modules share the same VPC/networking infrastructure
- The modules are independent - applying one doesn't affect the other
- Each module creates its own EC2 instances, EIPs, and Cloudflare DNS records
- See [AAPAIO_README.md](AAPAIO_README.md) for aapaio-specific documentation

## Architecture

**Network:**
- VPC: 10.0.0.0/16
- 2 Public Subnets (bastion)
- 2 Private Subnets (AAP nodes)
- NAT Gateway for private subnet internet access
- S3 VPC Endpoint for EFS

**Security:**
- AAP nodes: Private IPs only, no direct internet access
- Bastion: Single entry point with Elastic IP (static)
- Security Groups: Bastion → AAP (SSH)

**Load Balancer:**
- Nginx on jumpserver with Let's Encrypt SSL
- Load balances to AAP Gateway nodes (port 8446)
- Uses `least_conn` algorithm
- WebSocket support for AAP UI

## Cleanup

### Destroy Infrastructure

```bash
terraform destroy
```

**What happens:**
- All infrastructure destroyed including Elastic IP
- Cloudflare DNS automatically updates to new IP on next apply

**After destroy → apply:**
1. `terraform apply` (new infrastructure + Cloudflare DNS auto-updates)
2. Re-run nginx playbook (obtain new SSL cert)
3. Re-install AAP

### Step 8. Destroy Lab Once you are Done

As we know, we are dealing with FREE tier, remember to destroy the resources once you finish the lab or practicing for that day.

```shell
$ terraform destroy
```

## Appendix

### Use `local-exec` if you have Ansible installed locally

If you are using Linux/Mac machine and ansible is available locally, then you an use below method for executing Terraform provisioner. (Current configuration is to execute ansible playbook  from `ansible-engine` node itself.)

```json
  provisioner "local-exec" {
    command = "ansible-playbook engine-config.yaml"
  }
```