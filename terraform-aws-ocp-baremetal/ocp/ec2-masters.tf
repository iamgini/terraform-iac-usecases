# ============================================================
# Master Nodes (Control Plane)
# ============================================================
# - Placed in PRIVATE subnets (outbound internet via NAT Gateway)
# - No public IPs — they resolve api-int via Route53 private zone → internal NLB
# - User data is base64-encoded master.ign (small pointer to MCS on api-int:22623)
# - Distributed across AZs using index modulo on private_subnet_ids
# - Registered in all API target groups (external + internal, 6443 + 22623)
# ============================================================

resource "aws_instance" "ocp_masters" {
  count = var.master_count

  ami                    = var.ami
  instance_type          = var.master_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids

  # Distribute masters across private subnets (AZs) round-robin
  subnet_id = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]

  # master.ign is a small pointer to MCS: https://api-int.<cluster>:22623/config/master
  # Must be base64-encoded when passed as EC2 user data
  user_data_base64 = var.master_ign_b64

  root_block_device {
    volume_size = var.master_root_volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name = var.master_node_names[count.index]
  }
}

# ============================================================
# Register masters in all API target groups
# ============================================================

resource "aws_lb_target_group_attachment" "masters_external_6443" {
  count            = var.master_count
  target_group_arn = var.tg_api_external_6443_arn
  target_id        = aws_instance.ocp_masters[count.index].id
  port             = 6443
}

resource "aws_lb_target_group_attachment" "masters_external_22623" {
  count            = var.master_count
  target_group_arn = var.tg_api_external_22623_arn
  target_id        = aws_instance.ocp_masters[count.index].id
  port             = 22623
}

resource "aws_lb_target_group_attachment" "masters_internal_6443" {
  count            = var.master_count
  target_group_arn = var.tg_api_internal_6443_arn
  target_id        = aws_instance.ocp_masters[count.index].id
  port             = 6443
}

resource "aws_lb_target_group_attachment" "masters_internal_22623" {
  count            = var.master_count
  target_group_arn = var.tg_api_internal_22623_arn
  target_id        = aws_instance.ocp_masters[count.index].id
  port             = 22623
}
