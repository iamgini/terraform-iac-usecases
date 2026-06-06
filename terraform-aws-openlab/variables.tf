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

variable "aap_node_count" {
  type        = number
  description = "Number of AAP nodes to create (minimum 2 recommended for HA)"
  default     = 9

  validation {
    condition     = var.aap_node_count >= 1 && var.aap_node_count <= 10
    error_message = "AAP node count must be between 1 and 10."
  }
}

variable "lab_security_group_name" {
  default = "openlab-sg"
}


variable "jumpserver_instance_type" {
  type        = string
  description = "Instance type for the jumpserver"
  default     = "t2.micro"
}

variable "enable_public_ip_aap" {
  type        = bool
  description = "Enable public IP for AAP nodes (set to false to use jumpserver only)"
  default     = false
}

# Cloudflare and DNS variables
variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token with DNS edit permissions"
  sensitive   = true
  default     = ""
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID for gineesh.com (NOT lab.gineesh.com - that's just a subdomain)"
  default     = ""
}

variable "aap_domain_name" {
  type        = string
  description = "Primary domain name for AAP"
  default     = "aap.lab.gineesh.com"
}

variable "aap_subdomain" {
  type        = string
  description = "Subdomain for AAP (without the base domain)"
  default     = "aap"
}

variable "aap_domain_sans" {
  type        = list(string)
  description = "Subject Alternative Names for the certificate"
  default     = ["*.aap.lab.gineesh.com"]
}

variable "cloudflare_proxied" {
  type        = bool
  description = "Enable Cloudflare proxy (orange cloud)"
  default     = false
}

variable "create_wildcard_dns" {
  type        = bool
  description = "Create wildcard DNS record for AAP subdomains"
  default     = true
}
