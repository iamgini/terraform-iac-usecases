variable "aws_region" {
  default     = "ap-southeast-1"
  description = "AWS region to deploy resources"
}

variable "aws_vpc_name" {
  default     = "openlab_vpc"
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "ssh_key_pair" {
  default     = "~/.ssh/id_rsa"
  description = "Path to private SSH key"
}

variable "ssh_key_pair_pub" {
  default     = "~/.ssh/id_rsa.pub"
  description = "Path to public SSH key"
}

variable "lab_security_group_name" {
  default     = "openlab-sg"
  description = "Name of the general lab security group (bastion etc)"
}

variable "ocp_cluster_name" {
  default     = "ocp420"
  description = "OCP cluster name — used in resource naming and DNS"
}

variable "ocp_base_domain" {
  default     = "gineesh.com"
  description = "Base domain for the OCP cluster"
}

# RHCOS AMI for OCP 4.20 in ap-southeast-1
# Get the correct AMI using:
#   openshift-install coreos print-stream-json | python3 -c "
#   import json, sys
#   data = json.load(sys.stdin)
#   amis = data['architectures']['x86_64']['images']['aws']['regions']
#   print('ap-southeast-1 AMI:', amis['ap-southeast-1']['image'])"
variable "rhcos_ami_id" {
  default     = "ami-0d191a1bffd735ebe"
  description = "RHCOS AMI ID for the target region — must match OCP installer version"
}

variable "aws_ami_id" {
  default     = "ami-0fbbafe729d214f98"
  description = "RHEL9 AMI for bastion node in ap-southeast-1"
}


# ============================================================
# OCP Module Variables
# Add these to your root variables.tf
# ============================================================

variable "bastion_private_ip" {
  type        = string
  default = ""
  description = "Bastion private IP — used to construct bootstrap.ign URL (http://<ip>:8080/bootstrap.ign)"
  # Find with: aws ec2 describe-instances --filters Name=tag:Name,Values=bastion \
  #   --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text
}

variable "master_ign_b64"     { default = "" }
variable "worker_ign_b64"     { default = "" }

variable "ocp_bootstrap_instance_type" {
  type        = string
  default     = "m5.xlarge"
  description = "Bootstrap instance type — temporary, terminated after install"
}

variable "ocp_master_instance_type" {
  type        = string
  default     = "m5.xlarge"
  description = "Master node instance type"
}

variable "ocp_worker_instance_type" {
  type        = string
  default     = "m5.xlarge"
  description = "Worker node instance type"
}

variable "ocp_master_count" {
  type        = number
  default     = 3
  description = "Number of master nodes — always 3 for production HA"
}

variable "ocp_worker_count" {
  type        = number
  default     = 3
  description = "Number of worker nodes"
}

variable "ocp_bootstrap_volume_size" {
  type        = number
  default     = 120
  description = "Bootstrap root volume size in GB"
}

variable "ocp_master_volume_size" {
  type        = number
  default     = 120
  description = "Master root volume size in GB"
}

variable "ocp_worker_volume_size" {
  type        = number
  default     = 120
  description = "Worker root volume size in GB"
}

variable "ocp_master_node_names" {
  type        = list(string)
  default     = ["ocp-master1", "ocp-master2", "ocp-master3"]
  description = "EC2 Name tags for master nodes — length must match ocp_master_count"
}

variable "ocp_worker_node_names" {
  type        = list(string)
  default     = ["ocp-worker1", "ocp-worker2", "ocp-worker3"]
  description = "EC2 Name tags for worker nodes — length must match ocp_worker_count"
}

# Enable or disable OCP nodes
variable "deploy_ocp_nodes" {
  type        = bool
  default     = false
  description = "Set to true after ignition configs are generated and HTTP server is running"
}