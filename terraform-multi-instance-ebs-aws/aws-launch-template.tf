resource "aws_launch_template" "multi-instance-lt" {
  name = "multi-instance-lt"

  # additional 2GB volume as /dev/sda1
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 2
    }
  }

  # additional 1GB volume as /dev/sda2
  block_device_mappings {
    device_name = "/dev/sda2"
    ebs {
      volume_size = 1
    }
  }
  
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  #cpu_options {
  #  core_count       = 1
  #  threads_per_core = 1
  #}

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_termination = true

  #ebs_optimized = true

  #elastic_gpu_specifications {
  #  type = "test"
  #}

  #elastic_inference_accelerator {
  #  type = "eia1.medium"
  #}

  #iam_instance_profile {
  #  name = "test"
  #}

  image_id = var.ami #"ami-test"

  instance_initiated_shutdown_behavior = "terminate"

  #instance_market_options {
  #  market_type = "spot"
  #}

  instance_type = "t2.micro"

  #kernel_id = "test"

  key_name = aws_key_pair.ec2loginkey.id #"ansible-lab-key"

  #license_specification {
  #  license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
  #}

  #metadata_options {
  #  http_endpoint               = "enabled"
  #  http_tokens                 = "required"
  #  http_put_response_hop_limit = 1
  #}

  #monitoring {
  #  enabled = true
  #}

  network_interfaces {
    associate_public_ip_address = true
  }

  #placement {
  #  availability_zone = "us-west-2a"
  #}

  #ram_disk_id = "test"

  #vpc_security_group_ids = ["sg-12345678"]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  #user_data = filebase64("${path.module}/example.sh")
}