
# output "ansible-engine" {
#   value = aws_instance.ansible-engine.public_ip
# }

# output "ansible-node-1" {
#   value = aws_instance.ansible-nodes[0].public_ip
# }

# output "ansible-node-2" {
#   value = aws_instance.ansible-nodes[1].public_ip
# }

output "aap_ec2_instances" {
  value = module.aap.ec2_instances
}

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

output "efs_dns_name" {
  value       = module.aap.efs_dns_name
  description = "EFS DNS name for mounting on AAP nodes"
}


output "aap_url" {
  value       = var.cloudflare_api_token != "" ? "https://${var.aap_domain_name}" : "Nginx LB: https://${aws_eip.jumpserver_eip.public_ip} (use custom domain or Cloudflare)"
  description = "AAP Access URL"
  sensitive   = true
}

output "cloudflare_dns_status" {
  value       = var.cloudflare_api_token != "" ? "Automated: ${var.aap_domain_name} → ${aws_eip.jumpserver_eip.public_ip}" : "Manual: Point ${var.aap_domain_name} to ${aws_eip.jumpserver_eip.public_ip} in Cloudflare"
  description = "Cloudflare DNS configuration status"
  sensitive   = true
}

# ================ AAP All-in-One Outputs =========================
output "aapaio_eip" {
  value       = module.aapaio.aapaio_eip
  description = "Elastic IP of AAP All-in-One"
}

output "aapaio_private_ip" {
  value       = module.aapaio.aapaio_private_ip
  description = "Private IP of AAP All-in-One"
}

output "aapaio_connection" {
  value       = module.aapaio.aapaio_connection
  description = "SSH command to connect to AAP All-in-One"
}

output "aapaio_url" {
  value       = var.cloudflare_api_token != "" ? "https://aapaio.lab.gineesh.com" : "https://${module.aapaio.aapaio_eip}"
  description = "AAP All-in-One Access URL"
  sensitive   = true
}

output "aapaio_cloudflare_dns_status" {
  value       = var.cloudflare_api_token != "" ? "Automated: aapaio.lab.gineesh.com → ${module.aapaio.aapaio_eip}" : "Manual: Point aapaio.lab.gineesh.com to ${module.aapaio.aapaio_eip} in Cloudflare"
  description = "Cloudflare DNS configuration status for AAP All-in-One"
  sensitive   = true
}

# Inventory helper outputs - use in your AAP inventory manually
output "inventory_ansible_ssh_common_args" {
  value       = "ansible_ssh_common_args='-o ProxyCommand=\"ssh -W %%h:%%p -i ~/.ssh/id_rsa ec2-user@${aws_eip.jumpserver_eip.public_ip}\" -o StrictHostKeyChecking=no'"
  description = "Add this to [all:vars] in your AAP inventory"
}

output "aap_inventory" {
  value = <<-EOT
# This section is for your AAP Gateway host(s)
# -----------------------------------------------------
[automationgateway]
%{for k, v in module.aap.ec2_instances~}
%{if length(regexall("^aap-gw", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

# This section is for your AAP Controller host(s)
# -----------------------------------------------------
[automationcontroller]
%{for k, v in module.aap.ec2_instances~}
%{if length(regexall("^aap-ac", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

# This section is for your AAP Execution host(s)
# -----------------------------------------------------
[execution_nodes]
# hop1.example.org receptor_type='hop'
# exec1.example.org
# exec2.example.org

# This section is for your AAP Automation Hub host(s)
# -----------------------------------------------------
[automationhub]
%{for k, v in module.aap.ec2_instances~}
%{if length(regexall("^aap-hub", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

# This section is for your AAP EDA Controller host(s)
# -----------------------------------------------------
[automationeda]
%{for k, v in module.aap.ec2_instances~}
%{if length(regexall("^aap-eda", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

[redis]
%{for k, v in module.aap.ec2_instances~}
%{if length(regexall("^aap-(gw|hub|eda)", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

[database]
%{for k, v in module.aap.ec2_instances~}
%{if length(regexall("^aap-db", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

[lab-lb]
jumpserver ansible_host=${aws_eip.jumpserver_eip.public_ip} ansible_ssh_common_args=''

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -i ~/.ssh/id_rsa ec2-user@${aws_eip.jumpserver_eip.public_ip}" -o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3.9
hub_shared_data_path=${module.aap.efs_dns_name}:/
EOT
  description = "Copy-paste ready AAP inventory format"
}
