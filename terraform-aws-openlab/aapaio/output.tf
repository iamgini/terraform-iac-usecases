output "aapaio_instance_id" {
  description = "Instance ID of AAP All-in-One"
  value       = aws_instance.aapaio.id
}

output "aapaio_private_ip" {
  description = "Private IP of AAP All-in-One"
  value       = aws_instance.aapaio.private_ip
}

output "aapaio_eip" {
  description = "Elastic IP of AAP All-in-One"
  value       = aws_eip.aapaio_eip.public_ip
}

output "aapaio_connection" {
  description = "SSH connection command for AAP All-in-One"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_eip.aapaio_eip.public_ip}"
}
