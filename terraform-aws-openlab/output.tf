
# output "ansible-engine" {
#   value = aws_instance.ansible-engine.public_ip
# }

# output "ansible-node-1" {
#   value = aws_instance.ansible-nodes[0].public_ip
# }

# output "ansible-node-2" {
#   value = aws_instance.ansible-nodes[1].public_ip
# }

output "aap_ec2_instances" {
  value = module.aap.ec2_instances
}
