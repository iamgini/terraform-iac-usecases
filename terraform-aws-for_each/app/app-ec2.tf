resource "aws_instance" "app-nodes" {
  for_each = var.app_instances
  instance_type   = each.value.instance_type
  associate_public_ip_address = each.value.public_ip_address

  ami             = var.ami
  key_name        = var.key_name
  subnet_id       = var.subnet_id
  security_groups = var.vpc_security_group_ids

  root_block_device {
    volume_size = each.value.volume_size       # Size in GB
    volume_type = "gp3"      # General Purpose SSD (adjust if necessary)
  }

  tags = {
    Name = each.key
  }
}


# resource "aws_instance" "app-nodes" {

#   ami             = var.ami
#   subnet_id       = var.subnet_id
#   instance_type   = var.instance_type
#   key_name        = var.key_name
#   count           = var.app_node_count
#   security_groups = var.vpc_security_group_ids
#   associate_public_ip_address = false

#   root_block_device {
#     volume_size = 40        # Size in GB
#     volume_type = "gp3"      # General Purpose SSD (adjust if necessary)
#   }

#   tags = {
#     Name = var.app_node_names[count.index]
#   }

# }
