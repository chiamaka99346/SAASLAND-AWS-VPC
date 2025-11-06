output "server_private_ip" {
  description = "Private IP of the app server"
  value       = aws_instance.server.private_ip
}

output "haproxy_public_ip" {
  description = "Public IP of the HAProxy instance"
  value       = aws_instance.haproxy.public_ip
}
