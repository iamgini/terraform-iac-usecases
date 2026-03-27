# ============================================================
# VPC Outputs
# ============================================================
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.openlab_vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (bastion, bootstrap)"
  value       = [aws_subnet.openlab_subnet_public1.id, aws_subnet.openlab_subnet_public2.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs (masters, workers)"
  value       = [aws_subnet.openlab_subnet_private1.id, aws_subnet.openlab_subnet_private2.id]
}

# ============================================================
# NAT Gateway
# ============================================================
output "nat_gateway_ip" {
  description = "Public IP of NAT Gateway (used by masters/workers for outbound internet)"
  value       = aws_eip.nat_gw_eip.public_ip
}

# ============================================================
# Load Balancer DNS Names
# ============================================================
output "api_external_nlb_dns" {
  description = "External API NLB DNS — use for api.* in Cloudflare"
  value       = aws_lb.ocp_api_external.dns_name
}

output "api_internal_nlb_dns" {
  description = "Internal API NLB DNS — used by Route53 private zone for api-int.*"
  value       = aws_lb.ocp_api_internal.dns_name
}

output "app_ingress_nlb_dns" {
  description = "App Ingress NLB DNS — use for *.apps.* in Cloudflare"
  value       = aws_lb.ocp_app_ingress.dns_name
}

# ============================================================
# Target Group ARNs — needed when registering EC2 instances
# ============================================================
output "tg_api_6443_arn" {
  description = "External TG ARN for port 6443 — register bootstrap + masters"
  value       = aws_lb_target_group.ocp_api_6443.arn
}

output "tg_api_22623_arn" {
  description = "External TG ARN for port 22623 — register bootstrap + masters"
  value       = aws_lb_target_group.ocp_api_22623.arn
}

output "tg_api_int_6443_arn" {
  description = "Internal TG ARN for port 6443 — register bootstrap + masters"
  value       = aws_lb_target_group.ocp_api_int_6443.arn
}

output "tg_api_int_22623_arn" {
  description = "Internal TG ARN for port 22623 — register bootstrap + masters"
  value       = aws_lb_target_group.ocp_api_int_22623.arn
}

output "tg_app_ingress_443_arn" {
  description = "Ingress TG ARN for port 443 — register workers"
  value       = aws_lb_target_group.ocp_app_ingress_443.arn
}

output "tg_app_ingress_80_arn" {
  description = "Ingress TG ARN for port 80 — register workers"
  value       = aws_lb_target_group.ocp_app_ingress_80.arn
}

# ============================================================
# Security Group IDs
# ============================================================
output "ocp_sg_id" {
  description = "OCP nodes security group ID — attach to bootstrap, masters, workers"
  value       = aws_security_group.ocp_sg.id
}

output "local_access_sg_id" {
  description = "Lab/bastion security group ID"
  value       = aws_security_group.local_access.id
}

# ============================================================
# Route53
# ============================================================
output "route53_private_zone_id" {
  description = "Route53 private hosted zone ID for OCP cluster"
  value       = aws_route53_zone.ocp_private_zone.zone_id
}

output "route53_private_zone_name" {
  description = "Route53 private hosted zone name"
  value       = aws_route53_zone.ocp_private_zone.name
}

# ============================================================
# DNS Records — copy these values to Cloudflare
# ============================================================
output "cloudflare_dns_instructions" {
  description = "DNS records to create in Cloudflare for public access"
  value = <<-EOT
    Create these CNAME records in Cloudflare under ${var.ocp_base_domain}:

    Name: api.${var.ocp_cluster_name}
    Target: ${aws_lb.ocp_api_external.dns_name}
    Purpose: Kubernetes API (external access)

    Name: *.apps.${var.ocp_cluster_name}
    Target: ${aws_lb.ocp_app_ingress.dns_name}
    Purpose: OCP application routes (console, apps)

    NOTE: api-int is handled by Route53 private zone — do NOT add to Cloudflare
  EOT
}

# ============================================================
# Key Pair
# ============================================================
output "key_pair_name" {
  description = "EC2 key pair name — use when launching instances"
  value       = aws_key_pair.ec2loginkey.key_name
}
