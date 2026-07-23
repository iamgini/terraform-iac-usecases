# AAP All-in-One (AAPAIO) Module

## Overview

This module deploys a single **AAP All-in-One** VM with 16 vCPU and 32GB RAM on AWS with:
- **Instance Type**: `c5.4xlarge` (16 vCPU, 32 GiB RAM)
- **Public subnet** placement with Elastic IP
- **Cloudflare DNS** automation: `aapaio.lab.gineesh.com`
- **RHEL 9** AMI (same as other AAP nodes)
- **200GB** root volume (gp3)

## Architecture

```
Internet
   │
   ▼
Elastic IP (auto-updated in Cloudflare)
   │
   ▼
AAPAIO Instance (c5.4xlarge)
   │
   └─ Public Subnet (openlab_subnet_public1)
   └─ Security Group: local_access (reused from AAP nodes)
```

## Quick Start

### 1. Deploy Infrastructure

```bash
# Initialize Terraform (first time only)
terraform init

# Preview changes
terraform plan

# Deploy (creates AAPAIO + updates Cloudflare DNS)
terraform apply
```

### 2. Access the Instance

```bash
# Get connection command
terraform output aapaio_connection

# Connect via SSH
ssh -i ~/.ssh/id_rsa ec2-user@<aapaio-eip>

# Or use DNS (if Cloudflare configured)
ssh -i ~/.ssh/id_rsa ec2-user@aapaio.lab.gineesh.com
```

### 3. Get Instance Details

```bash
# Elastic IP
terraform output aapaio_eip

# Private IP
terraform output aapaio_private_ip

# Access URL
terraform output aapaio_url

# DNS status
terraform output aapaio_cloudflare_dns_status
```

## Module Structure

```
aapaio/
├── ec2-aapaio.tf       # EC2 instance + EIP resources
├── variables.tf        # Module input variables
└── output.tf           # Module outputs
```

## Configuration

### Instance Specifications

- **Instance Type**: `c5.4xlarge`
  - 16 vCPU
  - 32 GiB RAM
  - Up to 10 Gbps network performance
  - EBS-optimized

- **Storage**: 200GB gp3 (suitable for all-in-one AAP setup)
- **Network**: Public subnet with Elastic IP
- **Security**: Reuses existing `local_access` security group (all AAP ports open)

### Cloudflare DNS

**Automated DNS record** (if `cloudflare_api_token` configured):
- **Name**: `aapaio.lab.gineesh.com`
- **Type**: A record
- **TTL**: 300 seconds
- **Proxied**: `false` (orange cloud OFF - direct access)

**Auto-updates** on EIP changes (destroy/apply cycles).

## Security Groups

**Reuses existing security group** `local_access` with ports:
- **22** (SSH)
- **80** (HTTP)
- **443** (HTTPS)
- **5432** (PostgreSQL)
- **6379, 16379** (Redis)
- **8443-8447** (AAP component ports)
- **27199** (Receptor)
- **50051** (gRPC)
- **ICMP** (Ping)

## Comparison: AAPAIO vs Multi-Node AAP

| Feature | AAPAIO (this module) | Multi-Node AAP (`aap` module) |
|---------|---------------------|-------------------------------|
| **Placement** | Public subnet | Private subnet |
| **Access** | Direct via EIP | Via jumpserver bastion |
| **Node Count** | 1 (all-in-one) | 9 (HA cluster) |
| **Instance Type** | c5.4xlarge | t2.xlarge (configurable) |
| **Use Case** | Demo/Dev/Testing | Production HA |
| **EFS** | Not included | Shared storage for Hubs |
| **DNS** | aapaio.lab.gineesh.com | aap.lab.gineesh.com (via jumpserver nginx) |

## Common Operations

### Install AAP All-in-One

```bash
# SSH to instance
ssh -i ~/.ssh/id_rsa ec2-user@$(terraform output -raw aapaio_eip)

# Download AAP installer
wget https://access.redhat.com/downloads/ansible-automation-platform-2.X

# Extract and configure inventory
tar xvf ansible-automation-platform-setup-bundle-2.X.tar.gz
cd ansible-automation-platform-setup-bundle-2.X

# Edit inventory (all-in-one setup)
vim inventory

# Run installer
sudo ./setup.sh
```

### Update Cloudflare DNS Manually

If `cloudflare_api_token` is not configured:

```bash
# Get EIP
terraform output aapaio_eip

# Manually update Cloudflare:
# 1. Go to Cloudflare dashboard → gineesh.com zone → DNS
# 2. Add/Update A record: aapaio.lab.gineesh.com → <aapaio-eip>
# 3. Set proxy to OFF (gray cloud)
```

### Destroy Infrastructure

```bash
terraform destroy

# Note: EIP is NOT preserved (will get new IP on next apply)
# Cloudflare DNS auto-updates to new IP if configured
```

## Troubleshooting

**Cannot SSH to instance:**
- Verify EIP: `terraform output aapaio_eip`
- Check security group allows SSH from your IP
- Verify key permissions: `chmod 600 ~/.ssh/id_rsa`

**DNS not resolving:**
- Check Cloudflare: `dig +short aapaio.lab.gineesh.com`
- Verify `cloudflare_api_token` is set
- Check `terraform output aapaio_cloudflare_dns_status`

**Instance undersized:**
- For production all-in-one, consider upgrading to `c5.9xlarge` (36 vCPU, 72 GiB)
- Update `instance_type` in `main.tf` module block

## Outputs Reference

| Output | Description |
|--------|-------------|
| `aapaio_eip` | Elastic IP address |
| `aapaio_private_ip` | Private IP in VPC |
| `aapaio_connection` | SSH command |
| `aapaio_url` | HTTPS access URL |
| `aapaio_cloudflare_dns_status` | DNS configuration status |

## Cost Estimate

**Approximate AWS costs** (us-east-2 region):
- `c5.4xlarge` instance: ~$0.68/hour (~$490/month)
- 200GB gp3 storage: ~$16/month
- Elastic IP (attached): Free
- Data transfer: Variable

**Total**: ~$506/month for 24/7 operation

## Integration with Existing Infrastructure

**Shared resources:**
- VPC: `openlab_vpc`
- Public subnet: `openlab_subnet_public1`
- Security group: `local_access`
- SSH key pair: `ec2loginkey`
- Cloudflare zone: `gineesh.com`

**Independent resources:**
- EC2 instance: `aapaio`
- Elastic IP: `aapaio-eip`
- Cloudflare DNS: `aapaio.lab.gineesh.com`

## Module Files

### `aapaio/ec2-aapaio.tf`
Creates EC2 instance, EIP, and EIP association.

### `aapaio/variables.tf`
Defines module inputs (AMI, instance type, subnet, security groups).

### `aapaio/output.tf`
Exports instance ID, IPs, and connection command.

### `cloudflare-dns-aapaio.tf` (root)
Creates Cloudflare A record pointing to AAPAIO EIP.

### Module invocation in `main.tf`
```hcl
module "aapaio" {
  source = "./aapaio"

  subnet_id              = aws_subnet.openlab_subnet_public1.id
  ami                    = var.aws_ami_id
  key_name               = aws_key_pair.ec2loginkey.key_name
  vpc_security_group_ids = [aws_security_group.local_access.id]
  instance_type          = "c5.4xlarge"
}
```

## Next Steps

1. **Deploy**: `terraform apply`
2. **Connect**: Use output SSH command
3. **Install AAP**: Download and run AAP installer
4. **Configure DNS**: Access via `https://aapaio.lab.gineesh.com`
5. **SSL**: Install Let's Encrypt certificate (optional)

---

**Note**: This module is designed for **development/testing** all-in-one AAP deployments. For **production HA**, use the multi-node `aap` module with jumpserver and EFS.
