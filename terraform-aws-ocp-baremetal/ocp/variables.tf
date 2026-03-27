# ============================================================
# Required — no defaults, must be passed from root module
# ============================================================
variable "ami" {
  type        = string
  description = "RHCOS AMI ID for the target region. Get via: openshift-install coreos print-stream-json"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH access"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to attach to OCP nodes (ocp-sg + any others)"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs — bootstrap goes here (needs EIP for internet via IGW)"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs — masters and workers go here (internet via NAT GW)"
}

variable "bootstrap_ign_url" {
  type        = string
  description = "URL to bootstrap.ign hosted on bastion, e.g. http://10.0.27.231:8080/bootstrap.ign"
}

variable "master_ign_b64" {
  type        = string
  description = "Base64-encoded contents of master.ign. Generate with: base64 -w0 master.ign"
  sensitive   = true
}

variable "worker_ign_b64" {
  type        = string
  description = "Base64-encoded contents of worker.ign. Generate with: base64 -w0 worker.ign"
  sensitive   = true
}

# ============================================================
# Target Group ARNs — for NLB registration
# ============================================================
variable "tg_api_external_6443_arn" {
  type        = string
  description = "External NLB target group ARN for port 6443 — register bootstrap + masters"
}

variable "tg_api_external_22623_arn" {
  type        = string
  description = "External NLB target group ARN for port 22623 — register bootstrap + masters"
}

variable "tg_api_internal_6443_arn" {
  type        = string
  description = "Internal NLB target group ARN for port 6443 — register bootstrap + masters"
}

variable "tg_api_internal_22623_arn" {
  type        = string
  description = "Internal NLB target group ARN for port 22623 — register bootstrap + masters"
}

variable "tg_app_ingress_443_arn" {
  type        = string
  description = "Ingress NLB target group ARN for port 443 — register workers"
}

variable "tg_app_ingress_80_arn" {
  type        = string
  description = "Ingress NLB target group ARN for port 80 — register workers"
}

# ============================================================
# Instance sizing — with sensible OCP defaults
# ============================================================
variable "bootstrap_instance_type" {
  type        = string
  default     = "m5.xlarge"
  description = "Bootstrap instance type — temporary, terminated after install"
}

variable "master_instance_type" {
  type        = string
  default     = "m5.xlarge"
  description = "Master node instance type"
}

variable "worker_instance_type" {
  type        = string
  default     = "m5.xlarge"
  description = "Worker node instance type"
}

variable "master_count" {
  type        = number
  default     = 3
  description = "Number of master nodes — must be 3 for HA"
}

variable "worker_count" {
  type        = number
  default     = 3
  description = "Number of worker nodes"
}

variable "bootstrap_root_volume_size" {
  type        = number
  default     = 120
  description = "Bootstrap root volume size in GB"
}

variable "master_root_volume_size" {
  type        = number
  default     = 120
  description = "Master root volume size in GB"
}

variable "worker_root_volume_size" {
  type        = number
  default     = 120
  description = "Worker root volume size in GB"
}

variable "volume_type" {
  type        = string
  default     = "gp3"
  description = "EBS volume type for all OCP nodes"
}

# ============================================================
# Naming
# ============================================================
variable "cluster_name" {
  type        = string
  default     = "ocp420"
  description = "OCP cluster name — used in EC2 Name tags"
}

variable "master_node_names" {
  type        = list(string)
  default     = ["ocp-master1", "ocp-master2", "ocp-master3"]
  description = "Name tags for master nodes — must match master_count"
}

variable "worker_node_names" {
  type        = list(string)
  default     = ["ocp-worker1", "ocp-worker2", "ocp-worker3"]
  description = "Name tags for worker nodes — must match worker_count"
}
