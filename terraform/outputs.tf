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

output "app_url" {
  description = "URL to access the Health Dashboard"
  value       = "http://${aws_instance.health_dashboard.public_ip}"
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://${aws_instance.health_dashboard.public_ip}:3000"
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "http://${aws_instance.health_dashboard.public_ip}:9090"
}
