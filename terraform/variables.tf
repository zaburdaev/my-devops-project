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
