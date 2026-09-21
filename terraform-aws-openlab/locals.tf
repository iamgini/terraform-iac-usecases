# Safe references to optional module outputs — empty/null when module is disabled
locals {
  aap_instances = var.enable_aap ? one(module.aap).ec2_instances : {}
  aap_efs_dns   = var.enable_aap ? one(module.aap).efs_dns_name : ""

  aapaio_eip      = var.enable_aapaio ? one(module.aapaio).aapaio_eip : ""
  aapaio_hostname = var.aapaio_domain_name

  aapaio_inventory_text = <<-EOT
[automationgateway]
${local.aapaio_hostname} ansible_host=${local.aapaio_eip}

[automationcontroller]
${local.aapaio_hostname} ansible_host=${local.aapaio_eip}

[automationhub]
${local.aapaio_hostname} ansible_host=${local.aapaio_eip}

[automationeda]
${local.aapaio_hostname} ansible_host=${local.aapaio_eip}

[redis]
${local.aapaio_hostname} ansible_host=${local.aapaio_eip}

[database]
${local.aapaio_hostname} ansible_host=${local.aapaio_eip}

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3.9
EOT

  aap_inventory_text = <<-EOT
[automationgateway]
%{for k, v in local.aap_instances~}
%{if length(regexall("^aap-gw", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

[automationcontroller]
%{for k, v in local.aap_instances~}
%{if length(regexall("^aap-ac", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

[execution_nodes]

[automationhub]
%{for k, v in local.aap_instances~}
%{if length(regexall("^aap-hub", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

[automationeda]
%{for k, v in local.aap_instances~}
%{if length(regexall("^aap-eda", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

[redis]
%{for k, v in local.aap_instances~}
%{if length(regexall("^aap-(gw|hub|eda)", v.name)) > 0~}
${v.name}.example.org ansible_host=${v.private_ip}
%{endif~}
%{endfor~}

[database]
%{for k, v in local.aap_instances~}
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
hub_shared_data_path=${local.aap_efs_dns}:/
EOT
}
