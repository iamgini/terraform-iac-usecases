# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform configuration for deploying **Ansible Automation Platform (AAP)** infrastructure on AWS with high availability, secure bastion access, and optional Cloudflare DNS automation.

**Key Infrastructure:**
- 9 AAP nodes (2 Controllers, 2 Gateways, 2 Hubs, 2 EDA Controllers, 1 Database)
- VPC with public/private subnets across 2 AZs
- Jumpserver (bastion) with persistent Elastic IP
- Application Load Balancer with 4 target groups (ports 8443-8446)
- EFS for shared AAP Hub content
- Nginx reverse proxy with Let's Encrypt SSL on jumpserver
- Optional Cloudflare DNS automation

**Default region:** `ap-southeast-2` (Asia Pacific - Sydney)

## Common Commands

### Terraform Workflow

```bash
# Initialize Terraform (first time or after module changes)
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply infrastructure (creates ~40+ resources)
terraform apply

# Destroy all infrastructure (keeps Elastic IP persistent)
terraform destroy
```

### Generate AAP Inventory

```bash
# View inventory
terraform output -raw aap_inventory

# Save to file for AAP installer
terraform output -raw aap_inventory > inventory-hosts.txt
```

### Access Infrastructure

```bash
# Get jumpserver SSH command
terraform output jumpserver_connection

# Connect to jumpserver
ssh -i ~/.ssh/id_rsa ec2-user@<jumpserver-eip>

# SSH to AAP nodes (from local machine, via bastion proxy)
ssh -i ~/.ssh/id_rsa -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/id_rsa ec2-user@<jumpserver-eip>" ec2-user@<aap-private-ip>
```

### Setup Nginx Load Balancer (HTTPS)

```bash
cd playbooks
ansible-playbook -i ../inventory.ini setup-nginx-lb.yml
```

This configures nginx on jumpserver with automated Let's Encrypt certificate for `https://aap.lab.gineesh.com`.

### Cloudflare DNS Automation

```bash
# Set environment variables (recommended)
export TF_VAR_cloudflare_api_token=$(cat ~/.config/cloudflare)
export TF_VAR_cloudflare_zone_id="your-zone-id"

# Or use terraform.tfvars (add to .gitignore)
# See CLOUDFLARE_SETUP.md for detailed setup

# Verify DNS after apply
terraform output cloudflare_dns_status
dig +short aap.lab.gineesh.com
```

## Architecture & Design Decisions

### Module Structure

- **Root module** (`*.tf` files): VPC, networking, security groups, jumpserver, Cloudflare DNS
- **AAP module** (`./aap/`): EC2 instances, ALB, EFS, target groups

The separation allows reusing the AAP module for different environments while keeping network infrastructure at root level.

### Security Model

**Private AAP nodes** (`enable_public_ip_aap = false`):
- No public IPs assigned to AAP instances
- All SSH access via jumpserver bastion
- Security group restricts ingress to jumpserver and ALB only
- NAT Gateway provides outbound internet for package updates

**Bastion pattern:**
- Single Elastic IP (persistent across destroy/apply)
- ProxyCommand in inventory allows AAP installer to reach private nodes from local machine
- Nginx reverse proxy on jumpserver terminates SSL and load balances to AAP gateways

### AAP Node Naming Convention

Nodes are named based on role (defined in `aap/variables.tf`):
- `aap-ac1`, `aap-ac2`: Automation Controllers
- `aap-gw1`, `aap-gw2`: Automation Gateways
- `aap-hub1`, `aap-hub2`: Automation Hubs
- `aap-eda1`, `aap-eda2`: Event-Driven Ansible
- `aap-db1`: Database server

The inventory template (`output.tf`) uses regex to group instances by role for AAP installer.

### Load Balancer Configuration

**ALB with 4 target groups:**
- Port 8443 → Automation Controllers (`aap-ac*`)
- Port 8444 → Automation Hubs (`aap-hub*`)
- Port 8445 → EDA Controllers (`aap-eda*`)
- Port 8446 → Automation Gateways (`aap-gw*`)

Target group attachments are dynamic based on node name patterns (see `aap/alb.tf`).

**Nginx reverse proxy:**
- Runs on jumpserver
- Terminates Let's Encrypt SSL
- Load balances to port 8446 (gateways) using `least_conn`
- WebSocket support for AAP UI

### EFS Storage

Shared storage for AAP Hub content across hub nodes. Mounted via NFS using EFS DNS name (output as `hub_shared_data_path` in inventory).

### Cloudflare Integration

**DNS automation:**
- Creates A record: `aap.lab.gineesh.com` → Jumpserver EIP
- Optional wildcard: `*.aap.lab.gineesh.com` (if `create_wildcard_dns = true`)
- Zone must be `gineesh.com` (NOT `lab.gineesh.com` - that's a subdomain)

**Important:** `cloudflare_proxied = false` - Let's Encrypt requires direct access to jumpserver for certificate validation.

### Terraform State & Outputs

Key outputs for post-deployment:
- `aap_inventory`: Full AAP inventory with bastion proxy config
- `jumpserver_connection`: SSH command for bastion
- `alb_dns_name`: Direct ALB access (not used in production - nginx on jumpserver is preferred)
- `cloudflare_dns_status`: DNS configuration status

## Configuration Variables

### Core Variables (variables.tf)

- `aap_node_count`: Number of AAP nodes (1-10, default 9)
- `enable_public_ip_aap`: Enable public IPs for AAP nodes (default `false`)
- `jumpserver_instance_type`: Jumpserver size (default `t2.micro`)
- `ssh_key_pair`: Path to SSH private key (default `~/.ssh/id_rsa`)
- `aws_ami_id`: AMI for instances (default RHEL9 in ap-southeast-2)

### AAP Module Variables (aap/variables.tf)

- `instance_type`: AAP node size (default `t2.xlarge`)
- `aap_node_names`: Ordered list of node names (ac, gw, hub, eda, db)

### DNS Variables

- `aap_domain_name`: Primary domain (default `aap.lab.gineesh.com`)
- `cloudflare_api_token`: Cloudflare API token (sensitive, optional)
- `cloudflare_zone_id`: Zone ID for `gineesh.com` (optional)

## File Organization

**Network infrastructure:**
- `aws-vpc*.tf`: VPC, subnets, route tables
- `aws-security_group.tf`: Security groups for bastion and AAP nodes
- `aws-internet-gw*.tf`, `aws-routes.tf`: Internet gateway and routing
- `aws-vpc-endpoints.tf`: S3 endpoint for EFS

**Compute:**
- `jumpserver.tf`: Bastion instance with Elastic IP and Cloudflare DNS
- `aws-ec2-keypair.tf`: SSH key pair resource
- `aap/ec2-aap.tf`: AAP node instances
- `aap/alb.tf`: Application Load Balancer and target groups
- `aap/efs.tf`: EFS file system and mount targets

**Configuration:**
- `main.tf`: Provider configuration and AAP module invocation
- `variables.tf`, `aap/variables.tf`: Input variables
- `output.tf`, `aap/output.tf`: Outputs
- `versions.tf`: Terraform and provider version constraints
- `acm-certificate.tf`: ACM certificate (optional, not used - Let's Encrypt preferred)

**Ansible:**
- `playbooks/setup-nginx-lb.yml`: Nginx + Let's Encrypt automation
- `ansible-inventory-template.ini`: Template for AAP inventory format

## Working with This Codebase

### When Modifying AAP Node Count

1. Update `aap_node_count` in `variables.tf` or `terraform.tfvars`
2. Ensure `aap_node_names` in `aap/variables.tf` has enough entries
3. Run `terraform plan` to verify which nodes will be created/destroyed
4. After apply, regenerate inventory: `terraform output -raw aap_inventory`

### When Adding New AAP Components

If adding new AAP node types (e.g., execution nodes):
1. Add names to `aap_node_names` in `aap/variables.tf`
2. Update inventory template in `output.tf` with new sections and regex patterns
3. Add ALB target group in `aap/alb.tf` if new port mapping needed
4. Update security group rules if new port access required

### When Changing SSH Keys

If using keys other than `~/.ssh/id_rsa`:
1. Update `ssh_key_pair` and `ssh_key_pair_pub` in `variables.tf` or `terraform.tfvars`
2. Regenerate inventory to update `ansible_ssh_private_key_file` path
3. Remember to use `-i` flag with correct key when SSHing

### Cloudflare DNS Changes

- Zone MUST be the root domain (`gineesh.com`), not subdomain
- API token needs "Zone DNS Edit" + "Zone Read" permissions
- Setting `cloudflare_proxied = true` will break Let's Encrypt (use `false`)
- Elastic IP is persistent - DNS updates automatically on apply

### Destroying and Recreating

**What persists:**
- Elastic IP (`aws_eip.jumpserver_eip` lifecycle: `create_before_destroy`)
- Cloudflare DNS auto-updates to same EIP

**After destroy → apply:**
1. Infrastructure recreates with same jumpserver IP
2. Regenerate inventory: `terraform output -raw aap_inventory > inventory.ini`
3. Re-run nginx playbook: `ansible-playbook -i inventory.ini setup-nginx-lb.yml`
4. Re-install AAP using new inventory

### Instance Type Recommendations

- **AAP Controllers/Gateways/Hubs**: Minimum `t2.xlarge` (4 vCPU, 16GB RAM)
- **Database**: `t2.xlarge` or larger for production
- **Jumpserver**: `t2.micro` sufficient (just SSH bastion + nginx proxy)

## Common Issues

**Let's Encrypt certificate fails:**
- Verify DNS resolves: `dig +short aap.lab.gineesh.com`
- Check Cloudflare proxy is OFF (gray cloud, not orange)
- Ensure port 80 and 443 are open on jumpserver security group

**Cannot SSH to AAP nodes:**
- Verify jumpserver is accessible: `ssh ec2-user@<jumpserver-eip>`
- Check AAP node private IPs: `terraform output aap_ec2_instances`
- Verify ProxyCommand syntax in inventory includes correct jumpserver IP

**Terraform state issues:**
- State is local (`terraform.tfstate`) - not using remote backend
- Do not commit `terraform.tfstate` to git (add to `.gitignore`)
- For team collaboration, consider migrating to S3 backend

**Module not found:**
- Run `terraform init` to download AAP module (it's a local path module)
- Ensure `./aap/` directory exists with module files
