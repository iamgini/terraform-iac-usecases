variable "aws_ami_id" {
  ## Amazon Linux 2 AMI (HVM)
  # default = "ami-02f26adf094f51167"

  # RHEL9 AMI in ap-southeast-2
  default = "ami-0705fe1e9a50e0d57"

  ## "ami-0cd31be676780afa7"
}

variable "aws_vpc_name" {
  default     = "openlab_vpc"
  description = "Name of the VPC"
}

variable "ssh_key_pair" {
  default = "~/.ssh/id_rsa"
  #default = "~/.ssh/id_rsa_ansilble_lab"
}

variable "ssh_key_pair_pub" {
  default = "~/.ssh/id_rsa.pub"
  #default = "~/.ssh/id_rsa_ansilble_lab.pub"
}

variable "ocp_node_count" {
  default = 8
}

variable "lab_security_group_name" {
  default = "openlab-sg"
}


# ============================================================
# OCP Module Variables
# Add these to your root variables.tf
# ============================================================

variable "bastion_private_ip" {
  type        = string
  description = "Bastion private IP — used to construct bootstrap.ign URL (http://<ip>:8080/bootstrap.ign)"
  # Find with: aws ec2 describe-instances --filters Name=tag:Name,Values=bastion \
  #   --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text
}

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