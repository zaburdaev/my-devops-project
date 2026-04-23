# =============================================================================
# Terraform Outputs
# Author: Vitalii Zaburdaiev | DevOpsUA6
# =============================================================================

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.health_dashboard.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.health_dashboard.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.health_dashboard.public_dns
}

output "elastic_ip" {
  description = "Elastic IP address (static)"
  value       = aws_eip.app_eip.public_ip
}

output "app_url" {
  description = "URL to access the Health Dashboard"
  value       = "http://${aws_eip.app_eip.public_ip}"
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://${aws_eip.app_eip.public_ip}:3000"
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "http://${aws_eip.app_eip.public_ip}:9090"
}

output "ssh_private_key" {
  description = "Private SSH key for EC2 access"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh -i my-devops-key.pem ec2-user@${aws_eip.app_eip.public_ip}"
}
