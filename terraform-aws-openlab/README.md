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
- **Application Load Balancer (ALB)** with target groups for each AAP component
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
jumpserver_public_ip = "3.24.28.76"
alb_dns_name = "aap-alb-xxxxxxxxx.ap-southeast-2.elb.amazonaws.com"
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
# ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -i ~/.ssh/id_rsa ec2-user@3.24.28.76" -o StrictHostKeyChecking=no'
```

**Usage:**
1. Copy the output into your AAP inventory file
2. Add your AAP-specific variables (admin passwords, registry credentials, etc.)
3. Run AAP installer from your local machine - it will proxy through bastion automatically!

## Step 6. Setup Nginx Load Balancer (HTTPS)

Configure nginx on jumpserver with Let's Encrypt SSL:

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
ssh -i ~/.ssh/id_rsa ec2-user@3.24.28.76
```

**Connect to AAP nodes via Bastion (from local machine):**

The inventory already includes the bastion proxy configuration. When you run the AAP installer from your local machine, it automatically connects through the bastion to reach the private AAP nodes.

**Manual SSH to AAP nodes (for troubleshooting):**
```shell
# Via ProxyCommand
ssh -i ~/.ssh/id_rsa -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/id_rsa ec2-user@3.24.28.76" ec2-user@10.0.13.69
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

## Architecture

**Network:**
- VPC: 10.0.0.0/16
- 2 Public Subnets (bastion + ALB)
- 2 Private Subnets (AAP nodes)
- NAT Gateway for private subnet internet access
- S3 VPC Endpoint for EFS

**Security:**
- AAP nodes: Private IPs only, no direct internet access
- Bastion: Single entry point with Elastic IP (static)
- Security Groups: Bastion → AAP (SSH), ALB → AAP (ports 8443-8446)

**Load Balancer:**
- ALB with 4 target groups:
  - Port 8443: Automation Controller
  - Port 8444: Automation Hub
  - Port 8445: Event-Driven Ansible
  - Port 8446: Automation Gateway

## Cleanup

### Destroy Infrastructure

```bash
terraform destroy
```

**What survives:**
- Elastic IP (persistent) - same IP on next apply
- Cloudflare DNS auto-updates to EIP

**After destroy → apply:**
1. `terraform apply` (infrastructure + DNS auto-restored)
2. Re-run nginx playbook (new SSL cert)
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