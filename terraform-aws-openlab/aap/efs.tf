# ================ EFS for AAP Hub Storage =========================

# EFS File System
resource "aws_efs_file_system" "aap_hub_storage" {
  creation_token = "aap-hub-storage"
  encrypted      = true

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "aap-hub-storage"
    Purpose = "AAP Hub Shared Storage"
  }
}

# EFS Mount Targets - one per availability zone
resource "aws_efs_mount_target" "aap_hub_storage_az1" {
  file_system_id  = aws_efs_file_system.aap_hub_storage.id
  subnet_id       = var.subnet_id
  security_groups = var.vpc_security_group_ids
}

# Optionally add mount target for second AZ if needed
# resource "aws_efs_mount_target" "aap_hub_storage_az2" {
#   file_system_id  = aws_efs_file_system.aap_hub_storage.id
#   subnet_id       = var.subnet_id_az2
#   security_groups = var.vpc_security_group_ids
# }

# EFS Access Point for AAP Hub
resource "aws_efs_access_point" "aap_hub_access_point" {
  file_system_id = aws_efs_file_system.aap_hub_storage.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/hub"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name = "aap-hub-access-point"
  }
}
