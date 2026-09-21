
output "jumpserver_public_ip" {
  value       = aws_eip.jumpserver_eip.public_ip
  description = "Elastic IP of the jumpserver"
}

output "jumpserver_private_ip" {
  value       = aws_instance.jumpserver.private_ip
  description = "Private IP of the jumpserver"
}

output "jumpserver_connection" {
  value       = "ssh -i ${var.ssh_key_pair} ec2-user@${aws_eip.jumpserver_eip.public_ip}"
  description = "SSH command to connect to jumpserver"
}

# ================ AAP HA Cluster Outputs =========================
output "aap_ec2_instances" {
  value       = var.enable_aap ? one(module.aap).ec2_instances : null
  description = "AAP HA cluster EC2 instances (null when enable_aap = false)"
}

output "efs_dns_name" {
  value       = var.enable_aap ? one(module.aap).efs_dns_name : null
  description = "EFS DNS name for mounting on AAP nodes (null when enable_aap = false)"
}

output "aap_url" {
  value       = var.enable_aap ? (var.cloudflare_api_token != "" ? "https://${var.aap_domain_name}" : "Nginx LB: https://${aws_eip.jumpserver_eip.public_ip}") : null
  description = "AAP HA cluster access URL (null when enable_aap = false)"
  sensitive   = true
}

output "cloudflare_dns_status" {
  value       = var.enable_aap ? (var.cloudflare_api_token != "" ? "Automated: ${var.aap_domain_name} → ${aws_eip.jumpserver_eip.public_ip}" : "Manual: Point ${var.aap_domain_name} to ${aws_eip.jumpserver_eip.public_ip} in Cloudflare") : null
  description = "Cloudflare DNS status for AAP HA cluster (null when enable_aap = false)"
  sensitive   = true
}

output "inventory_ansible_ssh_common_args" {
  value       = var.enable_aap ? "ansible_ssh_common_args='-o ProxyCommand=\"ssh -W %%h:%%p -i ~/.ssh/id_rsa ec2-user@${aws_eip.jumpserver_eip.public_ip}\" -o StrictHostKeyChecking=no'" : null
  description = "Add this to [all:vars] in your AAP inventory (null when enable_aap = false)"
}

output "aap_inventory" {
  value       = var.enable_aap ? local.aap_inventory_text : null
  description = "Copy-paste ready AAP inventory (null when enable_aap = false)"
}

# ================ AAP All-in-One Outputs =========================
output "aapaio_eip" {
  value       = var.enable_aapaio ? one(module.aapaio).aapaio_eip : null
  description = "Elastic IP of AAP All-in-One (null when enable_aapaio = false)"
}

output "aapaio_private_ip" {
  value       = var.enable_aapaio ? one(module.aapaio).aapaio_private_ip : null
  description = "Private IP of AAP All-in-One (null when enable_aapaio = false)"
}

output "aapaio_connection" {
  value       = var.enable_aapaio ? one(module.aapaio).aapaio_connection : null
  description = "SSH command to connect to AAP All-in-One (null when enable_aapaio = false)"
}

output "aapaio_url" {
  value       = var.enable_aapaio ? "https://${var.aapaio_domain_name}" : null
  description = "AAP All-in-One access URL (null when enable_aapaio = false)"
  sensitive   = true
}

output "aapaio_cloudflare_dns_status" {
  value       = var.enable_aapaio ? (var.cloudflare_api_token != "" ? "Automated: ${var.aapaio_domain_name} → ${one(module.aapaio).aapaio_eip}" : "No DNS configured — add '${one(module.aapaio).aapaio_eip} ${var.aapaio_domain_name}' to /etc/hosts on the node") : null
  description = "Cloudflare DNS status for AAP All-in-One (null when enable_aapaio = false)"
  sensitive   = true
}

output "aapaio_inventory" {
  value       = var.enable_aapaio ? local.aapaio_inventory_text : null
  description = "Ready-to-use AAP installer inventory for All-in-One (null when enable_aapaio = false)"
  sensitive   = true
}
