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
