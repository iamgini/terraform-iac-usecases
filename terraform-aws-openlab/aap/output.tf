
# output "ansible-engine" {
#   value = aws_instance.ansible-engine.public_ip
# }

# output "aap-node-1" {
#   value = aws_instance.ansible-nodes[0].public_ip
# }

# output "ansible-node-2" {
#   value = aws_instance.ansible-nodes[1].public_ip
# }

output "aap_node_public_ips" {
  value = [for instance in aws_instance.aap-nodes : instance.public_ip]
  description = "Public IPs of all Ansible Node instances"
}
