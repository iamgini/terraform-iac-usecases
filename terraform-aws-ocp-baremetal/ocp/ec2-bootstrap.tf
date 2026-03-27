# ============================================================
# Bootstrap Node
# ============================================================
# - Placed in PUBLIC subnet (needs EIP for outbound internet via IGW)
# - User data is a small JSON pointer to bootstrap.ign on the bastion HTTP server
# - TEMPORARY — terminate after openshift-install wait-for bootstrap-complete
# - Registered in all API target groups (external + internal, 6443 + 22623)
# ============================================================

resource "aws_instance" "ocp_bootstrap" {
  ami                    = var.ami
  instance_type          = var.bootstrap_instance_type
  subnet_id              = var.public_subnet_ids[0]
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids

  # Bootstrap pointer — Ignition reads this and fetches the full bootstrap.ign
  # from the bastion HTTP server. bootstrap.ign is too large for EC2 user-data (>16KB limit)
  user_data = jsonencode({
    ignition = {
      config = {
        replace = {
          source = var.bootstrap_ign_url
        }
      }
      version = "3.2.0"
    }
  })

  root_block_device {
    volume_size = var.bootstrap_root_volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name = "${var.cluster_name}-bootstrap"
  }
}

# EIP for bootstrap — required because subnet has MapPublicIpOnLaunch=false
# Without this, IGW has no public IP to SNAT outbound traffic → node-image-pull fails
resource "aws_eip" "bootstrap_eip" {
  instance = aws_instance.ocp_bootstrap.id
  domain   = "vpc"

  tags = {
    Name = "${var.cluster_name}-bootstrap-eip"
  }
}

# ============================================================
# Register bootstrap in all API target groups
# Bootstrap serves the API and MCS during installation
# ============================================================

resource "aws_lb_target_group_attachment" "bootstrap_external_6443" {
  target_group_arn = var.tg_api_external_6443_arn
  target_id        = aws_instance.ocp_bootstrap.id
  port             = 6443
}

resource "aws_lb_target_group_attachment" "bootstrap_external_22623" {
  target_group_arn = var.tg_api_external_22623_arn
  target_id        = aws_instance.ocp_bootstrap.id
  port             = 22623
}

resource "aws_lb_target_group_attachment" "bootstrap_internal_6443" {
  target_group_arn = var.tg_api_internal_6443_arn
  target_id        = aws_instance.ocp_bootstrap.id
  port             = 6443
}

resource "aws_lb_target_group_attachment" "bootstrap_internal_22623" {
  target_group_arn = var.tg_api_internal_22623_arn
  target_id        = aws_instance.ocp_bootstrap.id
  port             = 22623
}
