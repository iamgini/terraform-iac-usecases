resource "aws_autoscaling_group" "multi-instance-asg" {
  name               = "multi-instance-asg"
  availability_zones = data.aws_availability_zones.az_list.names
  #vpc_zone_identifier       = var.vpc_zone_identifier
  #launch_configuration      = aws_launch_configuration.test.name
  #launch_template = "multi-instance-lt"
  launch_template {
    id      = aws_launch_template.multi-instance-lt.id
    version = "$Latest"
  }
  min_size                  = 3
  max_size                  = 3
  desired_capacity          = 3
  force_delete              = true
  wait_for_capacity_timeout = "15m"

  tag {
    key                 = "Name"
    value               = "multi-instances"
    propagate_at_launch = true
  }

  #tags = {
  #  Name = "multi-instance" #-${count.index + 1}"
  #}
  tag {
    key                 = "Environment"
    value               = "test"
    propagate_at_launch = true
  }

}