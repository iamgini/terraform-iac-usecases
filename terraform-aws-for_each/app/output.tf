
# output "ap_node_public_ips" {
#   value = [for instance in aws_instance.app-nodes : instance.public_ip]
#   description = "Public IPs of all Ansible Node instances"
# }

output "ec2_instances" {
  value = {
    for instance in aws_instance.app-nodes :
    instance.id => {
      name       = lookup(instance.tags, "Name", "Unknown")
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  }
}
