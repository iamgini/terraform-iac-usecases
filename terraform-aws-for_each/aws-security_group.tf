resource "aws_security_group" "local_access" {
  vpc_id      = aws_vpc.tbly_vpc.id
  name        = var.lab_security_group_name
  description = "Created by Terraform for local access"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "local_access"
  }
}

resource "aws_security_group_rule" "ingress_rules_local_access" {
  for_each = {
    for k, v in var.sg_ports_local_access : k => v
    if contains(keys(v), "port")  # filtering only ingress-like entries
  }

  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.local_access.id
  description       = each.value.description
  cidr_blocks       = ["0.0.0.0/0"]
}