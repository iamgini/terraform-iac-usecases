# ============================================================
# Worker Nodes (Compute)
# ============================================================
# - Placed in PRIVATE subnets (outbound internet via NAT Gateway)
# - No public IPs — application traffic arrives via Ingress NLB
# - User data is base64-encoded worker.ign (pointer to MCS on api-int:22623)
# - Distributed across AZs using index modulo on private_subnet_ids
# - Registered in Ingress NLB target groups (443 and 80)
# ============================================================

resource "aws_instance" "ocp_workers" {
  count = var.worker_count

  ami                    = var.ami
  instance_type          = var.worker_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids

  # Distribute workers across private subnets (AZs) round-robin
  subnet_id = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]

  # worker.ign is a pointer to MCS: https://api-int.<cluster>:22623/config/worker
  user_data_base64 = var.worker_ign_b64

  root_block_device {
    volume_size = var.worker_root_volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name = var.worker_node_names[count.index]
  }
}

# ============================================================
# Register workers in Ingress NLB target groups
# ============================================================

resource "aws_lb_target_group_attachment" "workers_ingress_443" {
  count            = var.worker_count
  target_group_arn = var.tg_app_ingress_443_arn
  target_id        = aws_instance.ocp_workers[count.index].id
  port             = 443
}

resource "aws_lb_target_group_attachment" "workers_ingress_80" {
  count            = var.worker_count
  target_group_arn = var.tg_app_ingress_80_arn
  target_id        = aws_instance.ocp_workers[count.index].id
  port             = 80
}
