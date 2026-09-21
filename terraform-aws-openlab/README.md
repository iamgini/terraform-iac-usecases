# AWS Ansible Automation Platform (AAP) Infrastructure

Terraform configuration for deploying Ansible Automation Platform on AWS with two deployment modes: a single **All-in-One** instance for dev/testing, or a full **9-node HA cluster** for production.

---

## Deployment Modes

| Mode | Module | Use Case | Nodes | Access |
|------|--------|----------|-------|--------|
| **All-in-One (AAPAIO)** | `aapaio` | Dev / Testing | 1 × `c5.4xlarge` | Direct EIP |
| **HA Cluster** | `aap` | Production | 9 × `t2.xlarge` | Via jumpserver |

Both modes share the same VPC, subnets, security groups, and SSH key pair. They are controlled by **feature flags** in `terraform.tfvars` — no code editing required.

---

## Prerequisites

1. **Terraform** ≥ 1.3 — [Install](https://developer.hashicorp.com/terraform/install)
2. **AWS credentials** configured (`aws configure` or environment variables)
3. **SSH key pair** at `~/.ssh/id_rsa` (or update `ssh_key_pair` in `terraform.tfvars`)
4. **Cloudflare** API token and Zone ID (optional — for automatic DNS)

```bash
ssh-keygen   # if you don't have a key pair yet
```

---

## Quick Start

```bash
git clone https://github.com/iamgini/terraform-iac-usecases
cd terraform-aws-openlab

terraform init
```

### 1. Choose deployment mode

Edit `terraform.tfvars` and set the feature flags:

```hcl
# Deploy All-in-One only (recommended for dev/testing)
enable_aapaio = true
enable_aap    = false

# Deploy HA cluster only (production)
enable_aapaio = false
enable_aap    = true

# Deploy both (uncommon — each is independent)
enable_aapaio = true
enable_aap    = true
```

### 2. Apply

```bash
terraform plan
terraform apply
```

That's it — no `-target` flags, no code commenting needed.

---

## Feature Flags Reference

All flags live in `terraform.tfvars`:

| Flag | Default | Description |
|------|---------|-------------|
| `enable_aapaio` | `false` | Enable AAP All-in-One single instance |
| `enable_aap` | `false` | Enable 9-node AAP HA cluster |
| `enable_public_ip_aap` | `false` | Give HA cluster nodes public IPs (not recommended) |
| `aap_node_count` | `9` | Number of nodes for the HA cluster (1–10) |
| `cloudflare_api_token` | `""` | Cloudflare API token (set via env var — see below) |
| `cloudflare_zone_id` | `""` | Cloudflare Zone ID for `gineesh.com` |

---

## Infrastructure Overview

### Shared Resources (always created)

- **VPC** — `10.0.0.0/16`
- **Public subnets** — `openlab_subnet_public1/2` (2 AZs)
- **Private subnets** — `openlab_subnet_private1/2` (2 AZs)
- **Internet Gateway** + public route table
- **NAT Gateway** — private subnet outbound internet
- **S3 VPC Endpoint** — for EFS access
- **Security groups** — `jumpserver_sg`, `local_access`
- **SSH key pair** — `openlab-key` (from `~/.ssh/id_rsa.pub`)
- **Jumpserver** — `t2.micro` Amazon Linux 2023, Elastic IP, Nginx proxy

### AAPAIO Module (`enable_aapaio = true`)

- **EC2**: `c5.4xlarge` (16 vCPU, 32 GiB RAM), RHEL 9, 200 GB gp3
- **Placement**: Public subnet with Elastic IP (direct internet access)
- **DNS**: `aapaio.lab.gineesh.com → <EIP>` (auto-created if Cloudflare configured)
- **Security group ports**: 22 (SSH), 80 (HTTP), 443 (HTTPS), 5432 (PostgreSQL), 6379/16379 (Redis), 8443–8447 (AAP components), 27199 (Receptor), 50051 (gRPC), ICMP

### AAP HA Cluster Module (`enable_aap = true`)

- **9 EC2 nodes** on private subnets (no public IPs):
  - `aap-ac1`, `aap-ac2` — Automation Controllers
  - `aap-gw1`, `aap-gw2` — Automation Gateways
  - `aap-hub1`, `aap-hub2` — Automation Hubs
  - `aap-eda1`, `aap-eda2` — Event-Driven Ansible
  - `aap-db1` — Database
- **EFS** — shared storage for Hub nodes
- **Access** — via jumpserver bastion only
- **SSL** — Nginx + Let's Encrypt on jumpserver
- **DNS**: `aap.lab.gineesh.com → <jumpserver-EIP>` (auto-created if Cloudflare configured)

---

## Outputs

### Always available

```bash
terraform output jumpserver_public_ip      # Jumpserver EIP
terraform output jumpserver_connection     # SSH command for jumpserver
```

### When `enable_aapaio = true`

```bash
terraform output aapaio_eip                # AAPAIO Elastic IP
terraform output aapaio_private_ip         # AAPAIO private IP
terraform output aapaio_connection         # SSH command: ssh -i ~/.ssh/id_rsa ec2-user@<EIP>
terraform output aapaio_url                # https://aapaio.lab.gineesh.com (or https://<EIP>)
terraform output aapaio_cloudflare_dns_status
```

### When `enable_aap = true`

```bash
terraform output aap_ec2_instances         # Map of all 9 AAP nodes with IPs
terraform output efs_dns_name              # EFS mount path for Hub nodes
terraform output aap_inventory             # Ready-to-use AAP installer inventory
terraform output inventory_ansible_ssh_common_args
```

---

## Workspaces (Multi-Account Deployments)

Use Terraform workspaces to manage independent deployments from the same codebase.

| Workspace | Var File | Purpose |
|-----------|----------|---------|
| `default` | `terraform.tfvars` | Primary environment |
| `new-account` | `new-account.tfvars` | Separate AWS account |

```bash
terraform workspace list
terraform workspace select new-account
terraform plan -var-file=new-account.tfvars
terraform apply -var-file=new-account.tfvars
```

> Always match `AWS_PROFILE` (or env vars) to the active workspace — workspaces isolate state, not credentials.

---

## AAP All-in-One: Post-Deploy Steps

### SSH access

```bash
# Get the SSH command
terraform output aapaio_connection

# Connect
ssh -i ~/.ssh/id_rsa ec2-user@<aapaio-eip>

# Or via DNS (if Cloudflare configured)
ssh -i ~/.ssh/id_rsa ec2-user@aapaio.lab.gineesh.com
```

### Install AAP (all-in-one)

```bash
# On the AAPAIO instance:
wget https://access.redhat.com/downloads/ansible-automation-platform-<version>
tar xvf ansible-automation-platform-setup-bundle-<version>.tar.gz
cd ansible-automation-platform-setup-bundle-<version>
vim inventory     # configure all-in-one inventory
sudo ./setup.sh
```

---

## AAP HA Cluster: Post-Deploy Steps

### Generate AAP inventory

```bash
# View inventory
terraform output -raw aap_inventory

# Save to file for AAP installer
terraform output -raw aap_inventory > inventory-hosts.txt
```

The generated inventory includes the bastion ProxyCommand so the AAP installer reaches private nodes directly from your local machine.

### Setup Nginx load balancer (HTTPS)

```bash
terraform output -raw aap_inventory > inventory.ini
cd playbooks
ansible-playbook -i ../inventory.ini setup-nginx-lb.yml
```

This installs Nginx on the jumpserver, auto-obtains a Let's Encrypt certificate for `aap.lab.gineesh.com`, and configures load balancing to the AAP gateway nodes on port 8446.

### SSH to AAP nodes (from local machine)

```bash
# Via ProxyCommand through jumpserver
ssh -i ~/.ssh/id_rsa \
    -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/id_rsa ec2-user@<jumpserver-eip>" \
    ec2-user@<aap-node-private-ip>
```

---

## Cloudflare DNS Setup

> **Cloudflare is optional.** If you don't have a Cloudflare account or domain, just skip this section — no configuration change is needed. Both `cloudflare_api_token` and `cloudflare_zone_id` default to `""`, and all Cloudflare DNS resources are automatically skipped when the token is empty. Use `terraform output aapaio_eip` or `terraform output jumpserver_public_ip` to get the IP and update your DNS manually.

### Enabling Cloudflare DNS automation

Set credentials via environment variables — never put them in `.tfvars` files:

```bash
export TF_VAR_cloudflare_api_token=$(cat ~/.config/cloudflare)
export TF_VAR_cloudflare_zone_id="your-zone-id"
```

- Zone must be the root domain: `gineesh.com` (not `lab.gineesh.com`)
- API token needs: **Zone DNS Edit** + **Zone Read** permissions
- Keep `cloudflare_proxied = false` — Let's Encrypt requires direct access

```bash
# Verify DNS after apply
terraform output aapaio_cloudflare_dns_status
terraform output cloudflare_dns_status
dig +short aapaio.lab.gineesh.com
```

See [CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md) for full setup instructions.

---

## File Structure

```
terraform-aws-openlab/
├── main.tf                      # Providers + module invocations (feature-flagged)
├── variables.tf                 # All input variables incl. enable_aap / enable_aapaio
├── locals.tf                    # Computed locals (AAP inventory text, safe module refs)
├── output.tf                    # All outputs (null when module is disabled)
├── terraform.tfvars             # Feature flags + environment config
├── versions.tf                  # Terraform + provider version constraints
│
├── aws-vpc.tf                   # VPC
├── aws-vpc-subnets.tf           # Public + private subnets
├── aws-internet-gw*.tf          # Internet gateway + attachment
├── aws-routes.tf                # Route tables + routes
├── aws-route-table*.tf          # Route table definitions + associations
├── aws-security_group.tf        # Security groups
├── aws-ec2-keypair.tf           # SSH key pair
├── aws-vpc-endpoints.tf         # S3 VPC endpoint
├── aws-infra-setup.tf           # VPC endpoint route table associations
│
├── jumpserver.tf                # Bastion host + EIP + Nginx-ready SG
├── cloudflare-dns.tf            # Cloudflare DNS for jumpserver (HA cluster)
├── cloudflare-dns-aapaio.tf     # Cloudflare DNS for AAPAIO
│
├── aap/                         # AAP HA cluster module (9 nodes + EFS)
│   ├── ec2-aap.tf
│   ├── efs.tf
│   ├── variables.tf
│   └── output.tf
│
├── aapaio/                      # AAP All-in-One module
│   ├── ec2-aapaio.tf
│   ├── variables.tf
│   └── output.tf
│
└── playbooks/
    └── setup-nginx-lb.yml       # Nginx + Let's Encrypt on jumpserver
```

---

## Architecture Diagram

```
                        Internet
                           │
              ┌────────────┴────────────┐
              │                         │
     Jumpserver EIP               AAPAIO EIP
     (aap.lab.gineesh.com)   (aapaio.lab.gineesh.com)
              │                         │
    ┌─────────▼──────────┐   ┌──────────▼──────────┐
    │  Public Subnet AZ1  │   │  Public Subnet AZ1   │
    │  Jumpserver t2.micro│   │  AAPAIO c5.4xlarge   │
    │  Nginx + Let's Enc. │   │  All-in-One AAP       │
    └─────────────────────┘   └──────────────────────┘
              │
    ┌─────────▼──────────────────────────────────────┐
    │              Private Subnets (AZ1 + AZ2)        │
    │  aap-ac1  aap-ac2  aap-gw1  aap-gw2             │
    │  aap-hub1 aap-hub2 aap-eda1 aap-eda2 aap-db1   │
    └─────────────────────────────────────────────────┘
              │
         NAT Gateway (outbound internet)
```

---

## Configuration Reference

### Instance Types

| Resource | Default | Notes |
|----------|---------|-------|
| Jumpserver | `t2.micro` | Set `jumpserver_instance_type` in tfvars |
| AAPAIO | `c5.4xlarge` | 16 vCPU, 32 GiB — set in `main.tf` module block |
| AAP nodes | `t2.xlarge` | Set in `aap/variables.tf` |

### AMI

Default: RHEL 9 in `ap-southeast-2` — `ami-0705fe1e9a50e0d57`

Override with `aws_ami_id` in tfvars.

### Storage

- AAPAIO: 200 GB gp3 root volume
- AAP nodes: default EBS (modify in `aap/ec2-aap.tf`)
- EFS: shared across Hub nodes (HA cluster only)

---

## Common Operations

### Switch deployment mode

```bash
# Edit terraform.tfvars
enable_aapaio = false
enable_aap    = true

terraform apply   # Terraform handles the diff automatically
```

### Add a new workspace

```bash
terraform workspace new staging
cp terraform.tfvars staging.tfvars   # Edit with staging-specific values
terraform apply -var-file=staging.tfvars
```

### Rebuild after destroy

```bash
terraform destroy
terraform apply
# If HA cluster: regenerate inventory and re-run nginx playbook
terraform output -raw aap_inventory > inventory.ini
ansible-playbook -i inventory.ini playbooks/setup-nginx-lb.yml
```

---

## Troubleshooting

**Let's Encrypt certificate fails**
- Verify DNS resolves to jumpserver: `dig +short aap.lab.gineesh.com`
- Cloudflare proxy must be OFF (gray cloud, `cloudflare_proxied = false`)
- Ports 80 and 443 must be open on the jumpserver security group

**Cannot SSH to AAP nodes**
- Verify jumpserver is reachable: `ssh ec2-user@<jumpserver-eip>`
- Check node private IPs: `terraform output aap_ec2_instances`
- ProxyCommand in inventory must match current jumpserver IP (regenerate after destroy)

**Terraform state issues**
- State is local per workspace (`terraform.tfstate.d/<workspace>/`)
- Do NOT commit `.tfvars`, `*.tfstate`, or `inventory.ini` files (all gitignored)
- For team use: migrate state to an S3 backend

**Module output is `null`**
- Set the corresponding flag: `enable_aapaio = true` or `enable_aap = true`
- Run `terraform apply` to create the resources

---

## Cost Estimate

**AAPAIO only** (ap-southeast-2):

| Resource | Cost |
|----------|------|
| `c5.4xlarge` instance | ~$0.68/hr (~$490/month) |
| 200 GB gp3 storage | ~$16/month |
| Elastic IP (attached) | Free |
| **Total** | **~$506/month** |

**HA Cluster** (9 × `t2.xlarge`):

| Resource | Cost |
|----------|------|
| 9 × `t2.xlarge` instances | ~$1.50/hr (~$1080/month) |
| EFS storage | Variable |
| NAT Gateway | ~$45/month |
| **Total** | **~$1125+/month** |

> Destroy resources when not in use to avoid charges.

```bash
terraform destroy
```

---

## References

- [Cloudflare DNS setup](CLOUDFLARE_SETUP.md)
- [AAP 2.x Containerized Installer docs](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
