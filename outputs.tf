output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

#output "instance_public_dns" {
#  description = "The public DNS name of the EC2 instance"
#  value       = aws_instance.app_server.public_dns_name
#}

output "security_group_id" {
  description = "The ID of the created security group"
  value       = aws_security_group.main_vpc_sg.id
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main_vpc.id
}

output "ec2_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "eip_public_ip" {
  description = "The Elastic IP allocated to the instance"
  value       = aws_eip.nat_eip.public_ip
}

output "eip_allocation_id" {
  description = "The Elastic IP allocation ID (useful for association/disassociation)"
  value       = aws_eip.nat_eip.allocation_id
}

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}