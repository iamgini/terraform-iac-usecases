variable "ami" {
  type        = string
  description = "The AMI ID for the AAP All-in-One node"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
}

variable "instance_type" {
  type        = string
  description = "Instance type for AAP All-in-One (16 vCPU, 32GB RAM)"
  default     = "c5.4xlarge"
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID for the AAP All-in-One node (public subnet)"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "VPC security group IDs for the AAP All-in-One node"
}

variable "aapaio_domain_name" {
  type        = string
  description = "FQDN for the AAP All-in-One node — added to /etc/hosts on the instance at boot"
  default     = "aapaio.example.com"
}
