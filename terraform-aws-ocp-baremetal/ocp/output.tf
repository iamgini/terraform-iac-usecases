# ============================================================
# Bootstrap Outputs
# ============================================================
output "bootstrap_instance_id" {
  description = "Bootstrap EC2 instance ID — needed to deregister from TGs after install"
  value       = aws_instance.ocp_bootstrap.id
}

output "bootstrap_private_ip" {
  description = "Bootstrap private IP — use for SSH via bastion"
  value       = aws_instance.ocp_bootstrap.private_ip
}

output "bootstrap_public_ip" {
  description = "Bootstrap public IP (EIP)"
  value       = aws_eip.bootstrap_eip.public_ip
}

# ============================================================
# Master Outputs
# ============================================================
output "master_instance_ids" {
  description = "Master node EC2 instance IDs"
  value       = [for m in aws_instance.ocp_masters : m.id]
}

output "master_private_ips" {
  description = "Master node private IPs — use for SSH via bastion"
  value       = [for m in aws_instance.ocp_masters : m.private_ip]
}

output "masters" {
  description = "Master node details"
  value = {
    for m in aws_instance.ocp_masters :
    m.id => {
      name       = lookup(m.tags, "Name", "unknown")
      private_ip = m.private_ip
      subnet_id  = m.subnet_id
    }
  }
}

# ============================================================
# Worker Outputs
# ============================================================
output "worker_instance_ids" {
  description = "Worker node EC2 instance IDs"
  value       = [for w in aws_instance.ocp_workers : w.id]
}

output "worker_private_ips" {
  description = "Worker node private IPs"
  value       = [for w in aws_instance.ocp_workers : w.private_ip]
}

output "workers" {
  description = "Worker node details"
  value = {
    for w in aws_instance.ocp_workers :
    w.id => {
      name       = lookup(w.tags, "Name", "unknown")
      private_ip = w.private_ip
      subnet_id  = w.subnet_id
    }
  }
}

# ============================================================
# Convenience — post-install checklist
# ============================================================
output "post_install_cleanup" {
  description = "Commands to run after bootstrap-complete"
  value       = <<-EOT
    After 'openshift-install wait-for bootstrap-complete', run:

    # 1. Deregister bootstrap from all target groups
    aws elbv2 deregister-targets --target-group-arn ${var.tg_api_external_6443_arn}  --targets Id=${aws_instance.ocp_bootstrap.id}
    aws elbv2 deregister-targets --target-group-arn ${var.tg_api_external_22623_arn} --targets Id=${aws_instance.ocp_bootstrap.id}
    aws elbv2 deregister-targets --target-group-arn ${var.tg_api_internal_6443_arn}  --targets Id=${aws_instance.ocp_bootstrap.id}
    aws elbv2 deregister-targets --target-group-arn ${var.tg_api_internal_22623_arn} --targets Id=${aws_instance.ocp_bootstrap.id}

    # 2. Terminate bootstrap instance
    aws ec2 terminate-instances --instance-ids ${aws_instance.ocp_bootstrap.id}

    # 3. Stop bastion HTTP server
    kill $(lsof -t -i:8080) && rm -rf ~/ignition-files/
  EOT
}
