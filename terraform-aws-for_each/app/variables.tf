variable "ami" {
  type        = string
  description = "The AMI ID for the node."
}

variable "key_name" {
  type        = string
}

variable "instance_type" {
  type = string
  description = "The instance type"
  default = "t2.micro"
}

variable "subnet_id" {
  type = string
  description = "The subnet ID for the node."
}

variable "app_node_names" {
  type    = list(string)
  default = ["web-front","web-back","web-db"]
}

variable "app_node_count" {
  type = number
  description = "Number of nodes for applications"
  default = 3
}

variable "app_instances" {
  description = "App instance details"
  default = {
    web-front = { instance_type = "t2.micro", volume_size = 40, public_ip_address = true }
    web-back = { instance_type = "t3.small", volume_size = 80, public_ip_address = false }
    web-db = { instance_type = "t3.small", volume_size = 200, public_ip_address = false }
  }
}


# variable "tags" {
#   type = map(string)
#   default = {}
#   description = "AWS tags to be applied to created resources."
# }

# variable "target_group_arns" {
#   type = list(string)
#   default = []
#   description = "The list of target group ARNs for the load balancer."
# }

# variable "target_group_arns_length" {
#   description = "The length of the 'target_group_arns' variable, to work around https://github.com/hashicorp/terraform/issues/12570."
# }

# variable "volume_iops" {
#   type = string
#   default = "100"
#   description = "The amount of IOPS to provision for the disk."
# }

# variable "volume_size" {
#   type = string
#   default = "200"
#   description = "The volume size (in gibibytes) for the node's root volume."
# }

# variable "storage_volume_size" {
#   type = string
#   default = "300"
#   description = "The volume size (in gibibytes) for the node's root volume."
# }

# variable "volume_type" {
#   type = string
#   default = "gp3"
#   description = "The volume type for the node's root volume."
# }

# variable "volume_kms_key_id" {
#   type = string
#   description = "The KMS key id that should be used to encrypt the node's root block device."
# }

# variable "vpc_id" {
#   type = string
#   description = "VPC ID is used to create resources like security group rules for machine."
# }

# variable "vpc_cidrs" {
#   type = list(string)
#   default = []
#   description = "VPC CIDR blocks."
# }

variable "vpc_security_group_ids" {
  type = list(string)
  default = []
  description = "VPC security group IDs for the node."
}

# variable "publish_strategy" {
#   type = string
#   description = "The publishing strategy for endpoints like load balancers"
# }

# variable "openshift_ssh_key" {
#   description = "Path to SSH Public Key file to use for OpenShift Installation"
#   type        = string
#   default     = ""
# }

# variable "openshift_version" {
#   type    = string
#   default = "4.14.38"
# }

# variable "base_domain" {
#   type        = string
#   description = "The DNS domain for the cluster."
# }

# variable "cluster_name" {
#   type        = string
#   description = "The identifier for the cluster."
# }