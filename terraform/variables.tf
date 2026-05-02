# =============================================================================
# Terraform Variables
# Author: Vitalii Zaburdaiev | DevOpsUA6
# =============================================================================

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "EC2 instance type (t3.micro is Free Tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 access"
  type        = string
  default     = "my-devops-key"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH (22). Restrict to your static IP in production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "existing_eip_allocation_id" {
  description = "Optional existing Elastic IP allocation ID to reuse (for stateless recovery runs)."
  type        = string
  default     = ""
}
