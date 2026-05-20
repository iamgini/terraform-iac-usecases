# Ansible Lab - Using Terraform and AWS

![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Free_Tier_Eligible-FF9900?logo=amazon-aws&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-Ready_to_Use-EE0000?logo=ansible&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

A complete **Infrastructure as Code (IaC)** solution to provision a ready-to-use Ansible lab environment in AWS. This project automatically creates a fully configured Ansible control node, managed nodes, and complete VPC networking infrastructure with just one command.

Perfect for learning Ansible, practicing DevOps, preparing for certifications, or testing automation workflows in a safe, isolated environment.

**Also check**: [Terraform IaC Examples](https://github.com/iamgini/terraform-iac-usecases)  
**Read Full Article**: [Use Terraform to Create a FREE Ansible Lab in AWS](https://www.techbeatly.com/2021/06/use-terraform-to-create-a-free-ansible-lab-in-aws.html)

## Quick Start

```shell
# Clone repository
git clone https://github.com/iamgini/terraform-iac-usecases
cd terraform-aws-ansible-lab

# Initialize and deploy
terraform init
terraform apply -auto-approve

# Get instance IPs
terraform output

# Access ansible-engine
ssh fedora@<ANSIBLE_ENGINE_IP>

# Test connectivity
ansible all -m ping
```

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [What This Project Creates](#what-this-project-creates)
- [Key Features](#key-features)
- [What You Can Practice](#what-you-can-practice)
- [How to Use This Repository](#how-to-use-this-repository)
- [Getting Started with Ansible](#getting-started-with-ansible)
- [Customization Options](#customization-options)
- [Cost Considerations](#cost-considerations)
- [Troubleshooting](#troubleshooting)
- [Appendix](#appendix)

## Prerequisites

Before you begin, ensure you have:

- ✅ **Terraform** installed (v1.0 or higher) - [Download](https://www.terraform.io/downloads.html)
- ✅ **AWS Account** with Free Tier eligibility
- ✅ **AWS CLI** configured with credentials - [Setup Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- ✅ **SSH Key Pair** (`~/.ssh/id_rsa` or custom key)
- ✅ **IAM Permissions** to create VPC, EC2, Security Groups
- ✅ Basic knowledge of AWS and Terraform (helpful but not required)

## What This Project Creates

This Terraform configuration provisions a complete AWS infrastructure for an Ansible lab environment:

### Networking Resources
- **VPC** - Custom Virtual Private Cloud with CIDR `10.1.0.0/16`
  - DNS support and DNS hostnames enabled
- **Subnets**:
  - 2x Public Subnets (`10.1.0.0/20`, `10.1.16.0/20`) in availability zones `ap-southeast-1a` and `ap-southeast-1b`
  - 2x Private Subnets (`10.1.128.0/20`, `10.1.144.0/20`) in availability zones `ap-southeast-1a` and `ap-southeast-1b`
- **Internet Gateway** - For public internet access
- **Route Tables**:
  - 1x Public Route Table (with internet gateway route)
  - 2x Private Route Tables
  - Route table associations for all subnets

### Security Resources
- **Security Group** - `ansible-lab-sg` with the following rules:
  - SSH access (port 22) from anywhere
  - HTTP access (port 80) from anywhere
  - ICMP (ping) enabled
  - All outbound traffic allowed

### Compute Resources
- **EC2 Key Pair** - SSH key pair for instance access
- **EC2 Instances**:
  - **1x Ansible Engine** - Control node where Ansible is configured
  - **2x Ansible Nodes** - Managed nodes for testing Ansible playbooks
  - All instances use `t2.micro` instance type (AWS Free Tier eligible)
  - AMI: **Fedora 43 Cloud Base** (`ami-04d824463ef922362`)
  - Deployed in public subnet with public IP addresses

### Automated Configuration
- **User Data Scripts** - Automatic installation and configuration on all nodes:
  - Ansible, Git, Vim, and essential packages installed
  - `devops` user created with password authentication
  - SSH keys configured for passwordless access
- **Ansible Inventory** - Auto-generated inventory file on ansible-engine with all node details
- **Ansible Configuration** - Pre-configured `ansible.cfg` for immediate use
- **Provisioners**:
  - Remote-exec provisioner creates inventory and ansible.cfg files
  - File provisioner copies engine-config.yaml
  - Ansible playbook execution for additional setup

## Key Features

- **Region**: `ap-southeast-1` (Singapore) - Configurable in `main.tf`
- **Node Count**: 2 managed nodes (configurable via `ansible_node_count` variable)
- **SSH Keys**: Uses `~/.ssh/id_rsa` by default (configurable in `variables.tf`)
- **Access Credentials**:
  - Username: `devops`
  - Password: `devops`
  - SSH keys pre-configured between ansible-engine and nodes
- **Ready to Use**: Ansible inventory and configuration files automatically created
- **Clean Destroy**: All resources cleanly removed with `terraform destroy`

## What You Can Practice

This lab environment is perfect for learning and practicing:

### Ansible Skills
- **Ad-hoc Commands** - Execute quick commands across multiple nodes
- **Playbooks** - Write and test playbooks for automation
- **Roles** - Create and organize reusable automation content
- **Variables & Facts** - Work with Ansible variables and gather facts
- **Templates** - Use Jinja2 templates for configuration management
- **Handlers** - Practice service restarts and notifications
- **Ansible Galaxy** - Install and use community roles
- **Ansible Vault** - Secure sensitive data
- **Dynamic Inventory** - Experiment with AWS dynamic inventory
- **Ansible Tower/AWX** - Install and test automation platform

### Linux Administration
- Package management (dnf/yum)
- User and permission management
- Service configuration and management
- Firewall configuration
- File system operations
- Network troubleshooting

### DevOps Practices
- Infrastructure as Code (Terraform)
- Configuration Management (Ansible)
- CI/CD pipeline setup
- Container deployment (Docker/Podman)
- Monitoring and logging setup
- Security hardening

### Terraform Skills
- Multi-resource deployment
- VPC and networking concepts
- EC2 instance management
- Provisioners (remote-exec, file)
- Output values
- State management

# How to Use This Repository
## Step 1. Install Terraform

If you haven't yet, [Download](https://www.terraform.io/downloads.html) and [Install](https://learn.hashicorp.com/tutorials/terraform/install-cli) Terraform.

## Step 2. Configure AWS Credential

Refer [AWS CLI Configuration Guide](https://github.com/iamgini/vagrant-iac-usecases#aws-setup) for details.

## Step 3. Create SSH Keys to Access the ec2 instances

If you have existing keys, you can use that; otherwise create new ssh keys.

- ***Warning**: Please remember to not to overwrite the existing ssh key pair files; use a new file name if you want to keep the old keys.*
- If you are using any key files other than `~/.ssh/id_rsa`, then remember to update the same in `variables.tf` as well.

```shell
$ ssh-keygen
```

## Step 4. Clone the Repository and Create Your Ansible Lab

```shell
$ git clone https://github.com/iamgini/terraform-iac-usecases
$ cd terraform-aws-ansible-lab

## Initialize Terraform
$ terraform init

## Verify the resource details before applying
$ terraform plan

## Apply configuration - This will create all AWS resources
$ terraform apply
.
.
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.ansible_lab_vpc: Creating...
aws_internet_gateway.ansible_lab_igw: Creating...
aws_key_pair.ec2loginkey: Creating...
aws_security_group.ansible_access: Creating...
aws_subnet.ansible_lab_subnet_public1: Creating...
aws_instance.ansible-engine: Creating...
aws_instance.ansible-nodes[0]: Creating...
aws_instance.ansible-nodes[1]: Creating...
.
.
Apply complete! Resources: 15+ added, 0 changed, 0 destroyed.

Outputs:

ansible-engine = <Public IP ADDRESS>
ansible-node-1 = <Public IP ADDRESS>
ansible-node-2 = <Public IP ADDRESS>
```

**Note**: The provisioning process takes approximately 3-5 minutes as it includes:
- Creating VPC and networking components
- Launching EC2 instances
- Running user-data scripts
- Configuring Ansible inventory
- Executing configuration playbooks

### How to Access the Lab

After successful deployment, Terraform outputs the public IP addresses of all instances.

#### Access Methods

**Option 1: Using devops user (Recommended for Ansible work)**
```shell
$ ssh devops@<ANSIBLE_ENGINE_PUBLIC_IP>
[devops@ansible-engine ~]$
```
- Username: `devops`
- Password: `devops`

**Option 2: Using fedora user (Default AMI user)**
```shell
$ ssh -i ~/.ssh/id_rsa fedora@<ANSIBLE_ENGINE_PUBLIC_IP>
[fedora@ansible-engine ~]$
```

#### Pre-configured Ansible Environment

All Ansible configuration files are automatically created in `/home/fedora/` directory:

```shell
[fedora@ansible-engine ~]$ ls -l
total 8
-rw-r--r-- 1 fedora fedora  100 May 21 10:04 ansible.cfg
-rw-r--r-- 1 fedora fedora  524 May 21 10:04 inventory
-rw-r--r-- 1 fedora fedora  256 May 21 10:04 engine-config.yaml
```

The inventory file contains all nodes with their private DNS names and connection details. SSH connectivity between ansible-engine and all managed nodes is pre-configured.

#### Verify Ansible Connectivity

Test connectivity to all nodes using the ping module:

```shell
[fedora@ansible-engine ~]$ ansible all -m ping
ansible-engine | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

#### Getting Node IP Addresses

View all instance public IPs:
```shell
$ terraform output
ansible-engine = "13.xxx.xxx.xxx"
ansible-node-1 = "13.xxx.xxx.xxx"
ansible-node-2 = "13.xxx.xxx.xxx"
```

## Getting Started with Ansible

Once you're logged into the ansible-engine, try these commands to get started:

### Basic Ad-hoc Commands

```shell
# Check uptime on all nodes
ansible all -m command -a "uptime"

# Get system information
ansible all -m setup

# Check disk space
ansible all -m shell -a "df -h"

# Install a package on all nodes
ansible nodes -m dnf -a "name=httpd state=present" --become

# Start a service
ansible nodes -m service -a "name=httpd state=started enabled=yes" --become

# Copy a file to all nodes
ansible all -m copy -a "src=/tmp/test.txt dest=/tmp/test.txt"

# Create a user
ansible all -m user -a "name=testuser state=present" --become

# Gather facts about a specific node
ansible node1 -m setup
```

### Sample Playbook

Create a simple playbook to install and configure a web server:

```shell
cat > webserver.yaml <<'EOF'
---
- name: Setup Web Server
  hosts: nodes
  become: yes
  tasks:
    - name: Install httpd
      dnf:
        name: httpd
        state: present
    
    - name: Start and enable httpd
      service:
        name: httpd
        state: started
        enabled: yes
    
    - name: Create index.html
      copy:
        content: "<h1>Hello from {{ inventory_hostname }}</h1>"
        dest: /var/www/html/index.html
    
    - name: Open firewall for HTTP
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes
EOF

# Run the playbook
ansible-playbook webserver.yaml
```

### Useful Ansible Commands

```shell
# List all hosts in inventory
ansible all --list-hosts

# Check ansible version
ansible --version

# Test connection to specific group
ansible nodes -m ping

# Run playbook in check mode (dry-run)
ansible-playbook webserver.yaml --check

# Run playbook with verbose output
ansible-playbook webserver.yaml -v
ansible-playbook webserver.yaml -vvv  # more verbose

# Run tasks step by step
ansible-playbook webserver.yaml --step

# Run specific tags
ansible-playbook webserver.yaml --tags "install"

# View inventory
ansible-inventory --list
ansible-inventory --graph
```

### Next Steps

- Create your own playbooks
- Install roles from Ansible Galaxy: `ansible-galaxy install <role-name>`
- Practice with Ansible Vault for sensitive data
- Experiment with templates using Jinja2
- Try deploying applications (Docker containers, web apps, etc.)
- Set up monitoring and logging solutions

## Step 5. Destroy Lab Once You Are Done

**Important**: To avoid unnecessary AWS charges, destroy the resources when not in use.

```shell
$ terraform destroy
```

You will be prompted to confirm:
```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

This will remove:
- All 3 EC2 instances (ansible-engine and 2 nodes)
- VPC and all subnets
- Internet Gateway
- Route tables and associations
- Security group
- SSH key pair

Don't worry - you can recreate the exact same environment anytime by running `terraform apply` again.

## Cost Considerations

**AWS Free Tier Eligible**: This lab is designed to run within AWS Free Tier limits:
- **t2.micro** instances (750 hours/month free for 12 months)
- **3 instances** = ~250 hours each if run continuously
- VPC, subnets, and route tables are free
- Data transfer within Free Tier limits

**Recommendations**:
- Destroy resources daily when not in use
- Monitor your AWS Free Tier usage in the AWS Console
- Set up billing alerts for unexpected charges

## Customization Options

All customizable variables are defined in `variables.tf`:

### Change AWS Region
Edit `main.tf`:
```hcl
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}
```

### Change Number of Ansible Nodes
Edit `variables.tf`:
```hcl
variable "ansible_node_count" {
  default = 3  # Increase or decrease as needed
}
```

### Use Different AMI
Edit `variables.tf`:
```hcl
variable "aws_ami_id" {
  default = "ami-xxxxxxxxx"  # Your preferred AMI ID
}
```
**Note**: If changing AMI/OS, update user-data scripts accordingly.

### Use Different SSH Keys
Edit `variables.tf`:
```hcl
variable "ssh_key_pair" {
  default = "~/.ssh/my-custom-key"
}
variable "ssh_key_pair_pub" {
  default = "~/.ssh/my-custom-key.pub"
}
```

### Change VPC CIDR or Subnet Configuration
Edit respective files in `aws-vpc.tf`, `aws-vpc-subnets.tf`

## Troubleshooting

### Instances not accessible via SSH
- Verify security group allows SSH from your IP
- Check that instances have public IPs
- Ensure SSH key pair is correct
- Wait 2-3 minutes after `terraform apply` for instances to fully initialize

### Ansible ping fails
- Wait for user-data scripts to complete (~3 minutes)
- Verify all instances are in "running" state
- Check security group allows ICMP and SSH within VPC
- SSH into ansible-engine and verify inventory file

### Terraform apply fails
- Check AWS credentials are configured correctly
- Verify you have appropriate IAM permissions
- Ensure the region supports the selected AMI
- Check AWS service limits for EC2 instances

### Resources not destroyed completely
```shell
$ terraform state list  # Check remaining resources
$ terraform destroy -auto-approve  # Force destroy
```

## Appendix

### Architecture Overview

```
Internet
    |
Internet Gateway
    |
VPC (10.1.0.0/16)
    |
    |-- Public Subnet 1 (10.1.0.0/20) - ap-southeast-1a
    |   |-- Ansible Engine
    |   |-- Ansible Node 1
    |   |-- Ansible Node 2
    |
    |-- Public Subnet 2 (10.1.16.0/20) - ap-southeast-1b
    |
    |-- Private Subnet 1 (10.1.128.0/20) - ap-southeast-1a
    |
    |-- Private Subnet 2 (10.1.144.0/20) - ap-southeast-1b
```

### File Structure

```
.
├── main.tf                          # Provider and outputs
├── variables.tf                     # Variable definitions
├── aws-vpc.tf                       # VPC configuration
├── aws-vpc-subnets.tf              # Subnet definitions
├── aws-internet-gw.tf              # Internet Gateway
├── aws-route-table.tf              # Route tables
├── aws-route-table-association.tf  # Route table associations
├── aws-routes.tf                   # Route definitions
├── security_group.tf               # Security group rules
├── ansible-engine.tf               # Ansible control node
├── ansible-nodes.tf                # Ansible managed nodes
├── user-data-ansible-engine.sh     # Bootstrap script for engine
├── user-data-ansible-nodes.sh      # Bootstrap script for nodes
└── engine-config.yaml              # Ansible playbook for setup
```

### Use `local-exec` if you have Ansible installed locally

If you are using Linux/Mac machine and Ansible is available locally, you can use the `local-exec` provisioner instead of `remote-exec`. (Current configuration executes the Ansible playbook from the `ansible-engine` node itself.)

```hcl
provisioner "local-exec" {
  command = "ansible-playbook engine-config.yaml"
}
```

### Useful Commands

```shell
# View current state
$ terraform show

# List all resources
$ terraform state list

# Get specific output
$ terraform output ansible-engine

# Format terraform files
$ terraform fmt

# Validate configuration
$ terraform validate

# Plan with variables
$ terraform plan -var="ansible_node_count=3"
```

## Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add some amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Areas for Contribution

- Support for additional Linux distributions (Ubuntu, CentOS, etc.)
- Additional Ansible playbook examples
- Multi-region support
- NAT Gateway configuration for private subnets
- Monitoring and logging setup
- Documentation improvements
- Bug fixes and optimizations

## Support

- **Issues**: Report bugs or request features via [GitHub Issues](https://github.com/iamgini/terraform-iac-usecases/issues)
- **Blog**: [TechBeatly.com](https://www.techbeatly.com)
- **Author**: [Gineesh Madapparambath](https://github.com/iamgini)

## Related Projects

- [Terraform IaC Use Cases](https://github.com/iamgini/terraform-iac-usecases)
- [Vagrant IaC Use Cases](https://github.com/iamgini/vagrant-iac-usecases)
- [Ansible Playbook Examples](https://github.com/iamgini/ansible-real-life)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Terraform by HashiCorp
- Ansible by Red Hat
- AWS Free Tier
- Open Source Community

---

**⭐ If you find this project helpful, please consider giving it a star!**

**Made with ❤️ for the DevOps Community**