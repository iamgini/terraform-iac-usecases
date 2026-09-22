# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform configuration for deploying **Ansible Automation Platform (AAP)** infrastructure on AWS with high availability, secure bastion access, and optional Cloudflare DNS automation.

**Key Infrastructure:**
- 9 AAP nodes (2 Controllers, 2 Gateways, 2 Hubs, 2 EDA Controllers, 1 Database)
- VPC with public/private subnets across 2 AZs
- Jumpserver (bastion) with Elastic IP
- EFS for shared AAP Hub content
- Nginx reverse proxy with Let's Encrypt SSL on jumpserver
- Optional Cloudflare DNS automation (auto-updates DNS on EIP changes)

**Default region:** `ap-southeast-2` (Asia Pacific - Sydney)

## Workspaces (Multi-Account Deployments)

This project uses **Terraform workspaces** to manage independent deployments from the same codebase. Each workspace has isolated state — applying in one never affects the other.

| Workspace | Var File | Purpose |
|---|---|---|
| `default` | `default.tfvars` | Existing AAP environment |
| `new-account` | `new-account.tfvars` | New AAP deployment (separate AWS account) |

```bash
terraform workspace list                  # List all workspaces
terraform workspace select default        # Switch to existing environment
terraform workspace select new-account    # Switch to new environment
```

**Rules:**
- Always use `-var-file=<workspace>.tfvars` — never use a bare `terraform.tfvars` (it auto-loads for all workspaces)
- Always set `AWS_PROFILE` (or env vars) matching the active workspace — workspaces isolate state, not credentials
- All `*.tfvars` files are gitignored except `terraform.tfvars.example`
- Workspace state is stored in `terraform.tfstate.d/<workspace>/` (gitignored)

**Adding a new workspace:**
```bash
terraform workspace new <name>
cp terraform.tfvars.example <name>.tfvars   # Edit with environment-specific values
```

## Common Commands

### Terraform Workflow

```bash
# Initialize Terraform (first time or after module changes)
terraform init

# Validate configuration
terraform validate

# Preview changes (always specify var-file for the active workspace)
terraform plan -var-file=<workspace>.tfvars

# Apply infrastructure (creates ~40+ resources)
terraform apply -var-file=<workspace>.tfvars

# Destroy all infrastructure (destroys everything including EIP)
terraform destroy -var-file=<workspace>.tfvars
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
# First, generate inventory from Terraform output
terraform output -raw aap_inventory > inventory.ini

# Then run nginx playbook
cd playbooks
ansible-playbook -i ../inventory.ini setup-nginx-lb.yml
```

This configures nginx on jumpserver with automated Let's Encrypt certificate for `https://aap.lab.gineesh.com`.

**Note:** `inventory.ini` is gitignored (contains actual IPs). Always regenerate from Terraform output.

### Cloudflare DNS Automation

```bash
# Set environment variables (recommended)
export TF_VAR_cloudflare_api_token=$(cat ~/.config/cloudflare)
export TF_VAR_cloudflare_zone_id="your-zone-id"

# Or add to your workspace-specific .tfvars file (all *.tfvars are gitignored)
# See CLOUDFLARE_SETUP.md for detailed setup

# Verify DNS after apply
terraform output cloudflare_dns_status
dig +short aap.lab.gineesh.com
```

## Architecture & Design Decisions

### Module Structure

- **Root module** (`*.tf` files): VPC, networking, security groups, jumpserver, Cloudflare DNS
- **AAP module** (`./aap/`): EC2 instances (9-node HA cluster), EFS
- **AAPAIO module** (`./aapaio/`): AAP All-in-One instance (c5.4xlarge, public subnet, EIP)

The separation allows reusing modules for different environments while keeping network infrastructure at root level.

### Security Model

**Private AAP nodes** (`enable_public_ip_aap = false`):
- No public IPs assigned to AAP instances
- All SSH access via jumpserver bastion
- Security group restricts ingress to jumpserver only
- NAT Gateway provides outbound internet for package updates

**Bastion pattern:**
- Single Elastic IP (not preserved on destroy - gets new IP on each apply)
- Cloudflare DNS auto-updates to new EIP when configured
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

**Nginx reverse proxy (on jumpserver):**
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
- `cloudflare_dns_status`: DNS configuration status
- `aap_url`: Access URL for AAP (via Nginx on jumpserver)

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

### AAPAIO Module Variables (aapaio/variables.tf)

- `instance_type`: AAPAIO node size (default `c5.4xlarge`)
- `aapaio_domain_name`: Passed from root — written to `/etc/hosts` and set as system hostname at boot via `user_data`

### DNS Variables

- `aap_domain_name`: Primary domain for AAP HA cluster (default `aap.lab.gineesh.com`)
- `aap_subdomain`: Subdomain for Cloudflare DNS record (default `aap.lab`)
- `aapaio_domain_name`: FQDN for AAPAIO node (default `aapaio.example.com`) — used in inventory, URL, and node `/etc/hosts`
- `aapaio_subdomain`: Subdomain for AAPAIO Cloudflare DNS record (default `aapaio.lab`)
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
- `aap/efs.tf`: EFS file system and mount targets

**SSL Strategy:**
- **NOT using AWS ACM or ALB** - using Let's Encrypt via Nginx on jumpserver
- Nginx playbook automatically obtains and renews certificates
- SSL termination happens on Nginx jumpserver

**Configuration:**
- `main.tf`: Provider configuration and AAP module invocation
- `variables.tf`, `aap/variables.tf`: Input variables
- `output.tf`, `aap/output.tf`: Outputs
- `versions.tf`: Terraform and provider version constraints
- `cloudflare-dns.tf`: Cloudflare DNS A records for AAP domain

**Ansible:**
- `playbooks/setup-nginx-lb.yml`: Nginx + Let's Encrypt automation
- `ansible-inventory-template.ini`: Template for AAP inventory format

## Working with This Codebase

### When Modifying AAP Node Count

1. Update `aap_node_count` in the workspace-specific `<workspace>.tfvars`
2. Ensure `aap_node_names` in `aap/variables.tf` has enough entries
3. Run `terraform plan` to verify which nodes will be created/destroyed
4. After apply, regenerate inventory: `terraform output -raw aap_inventory`

### When Adding New AAP Components

If adding new AAP node types (e.g., execution nodes):
1. Add names to `aap_node_names` in `aap/variables.tf`
2. Update inventory template in `output.tf` with new sections and regex patterns
3. Update security group rules if new port access required
4. Update Nginx configuration if new services need load balancing

### When Changing SSH Keys

If using keys other than `~/.ssh/id_rsa`:
1. Update `ssh_key_pair` and `ssh_key_pair_pub` in the workspace-specific `<workspace>.tfvars`
2. Regenerate inventory to update `ansible_ssh_private_key_file` path
3. Remember to use `-i` flag with correct key when SSHing

### Cloudflare DNS Changes

- Zone MUST be the root domain (`gineesh.com`), not subdomain
- API token needs "Zone DNS Edit" + "Zone Read" permissions
- Setting `cloudflare_proxied = true` will break Let's Encrypt (use `false`)
- Elastic IP is NOT preserved - Cloudflare DNS automatically updates to new IP on apply

### Destroying and Recreating

**What happens on destroy:**
- All infrastructure destroyed including Elastic IP
- Cloudflare DNS automatically updates to new IP on next apply

**After destroy → apply:**
1. Infrastructure recreates with new jumpserver IP
2. Cloudflare DNS auto-updates (if configured)
3. Regenerate inventory: `terraform output -raw aap_inventory > inventory.ini`
4. Re-run nginx playbook: `ansible-playbook -i inventory.ini setup-nginx-lb.yml`
5. Re-install AAP using new inventory

### Instance Type Recommendations

- **AAP Controllers/Gateways/Hubs**: Minimum `t2.xlarge` (4 vCPU, 16GB RAM)
- **Database**: `t2.xlarge` or larger for production
- **Jumpserver**: `t2.micro` sufficient (just SSH bastion + nginx proxy)

## AAPAIO Hostname (Non-Cloudflare)

AAP installer requires a proper FQDN — raw IPs are rejected. When Cloudflare is not configured:

1. **Node `/etc/hosts`** — automated via `user_data` at boot (private IP → hostname)
2. **Laptop `/etc/hosts`** — one manual step after `terraform apply`:
   ```bash
   # Get the EIP from output
   terraform output aapaio_eip
   # Add to /etc/hosts
   echo "<EIP>  <aapaio_domain_name>" | sudo tee -a /etc/hosts
   ```
   The `aapaio_cloudflare_dns_status` output prints the exact line to add.

Set your hostname in tfvars: `aapaio_domain_name = "aapaio.mylab.com"`

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
- State is local, isolated per workspace (`terraform.tfstate.d/<workspace>/`)
- The `default` workspace uses `terraform.tfstate` in the project root
- Do not commit state files, `*.tfvars`, or `inventory.ini` to git (all gitignored)
- For team collaboration, consider migrating to S3 backend

**Hardcoded IPs in documentation:**
- All example IPs use placeholders (`<JUMPSERVER_IP>`, `<AAP_NODE_PRIVATE_IP>`)
- Always use `terraform output` to get actual IPs
- `inventory.ini` is generated dynamically and gitignored

**Module not found:**
- Run `terraform init` to download AAP module (it's a local path module)
- Ensure `./aap/` directory exists with module files
