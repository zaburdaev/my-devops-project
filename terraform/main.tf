# =============================================================================
# Terraform configuration for Health Dashboard on AWS
# Author: Vitalii Zaburdaiev | DevOpsUA6
# Creates: EC2 instance (t2.micro) with Security Group
# Region: eu-central-1 (Frankfurt)
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# ---------- Provider ----------
provider "aws" {
  region = var.aws_region
}

# ---------- Data: Latest Amazon Linux 2023 AMI ----------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------- TLS Private Key ----------
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ---------- AWS Key Pair ----------
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name    = var.key_name
    Project = "my-devops-project"
  }
}

# ---------- Security Group ----------
resource "aws_security_group" "health_dashboard_sg" {
  name        = "health-dashboard-sg"
  description = "Security group for Health Dashboard application"

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App direct access
  ingress {
    description = "App"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana
  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus
  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "health-dashboard-sg"
    Project = "my-devops-project"
    Author  = "Vitalii Zaburdaiev"
  }
}

# ---------- EC2 Instance ----------
resource "aws_instance" "health_dashboard" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.health_dashboard_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  # User data script to install Docker and Docker Compose
  user_data = <<-EOF
    #!/bin/bash
    set -e
    # Update system
    yum update -y
    # Install Docker and Git
    yum install -y docker git
    systemctl start docker
    systemctl enable docker
    # Install Docker Compose (as CLI plugin and standalone)
    mkdir -p /usr/local/lib/docker/cli-plugins/
    curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    cp /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    # Install Docker Buildx
    BUILDX_VERSION="v0.21.1"
    curl -SL "https://github.com/docker/buildx/releases/download/$${BUILDX_VERSION}/buildx-$${BUILDX_VERSION}.linux-amd64" -o /usr/local/lib/docker/cli-plugins/docker-buildx
    chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx
    # Add ec2-user to docker group
    usermod -aG docker ec2-user
  EOF

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name    = "health-dashboard-server"
    Project = "my-devops-project"
    Author  = "Vitalii Zaburdaiev"
  }
}
