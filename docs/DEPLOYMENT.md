# 🚀 Deployment Guide

This guide covers all the ways you can deploy the **Health Monitoring Dashboard**. Choose the option that best fits your needs — from simple local Docker to full AWS cloud deployment.

---

## 📋 Table of Contents

- [Deployment Options Overview](#-deployment-options-overview)
- [Option 1: Local Deployment with Docker Compose](#-option-1-local-deployment-with-docker-compose)
- [Option 2: AWS Deployment with Terraform](#-option-2-aws-deployment-with-terraform)
- [Option 3: Kubernetes Deployment](#-option-3-kubernetes-deployment)
- [Option 4: Ansible Automation](#-option-4-ansible-automation)
- [Quick Comparison](#-quick-comparison)

---

## 🗺️ Deployment Options Overview

| Option | Difficulty | Best For | What You Need |
|--------|:----------:|----------|--------------|
| 🐳 **Docker Compose** | ⭐ Easy | Local development, demos | Docker + Docker Compose |
| ☁️ **Terraform (AWS)** | ⭐⭐ Medium | Cloud deployment | AWS account + Terraform |
| ⚙️ **Ansible** | ⭐⭐ Medium | Automating server setup | SSH access to a server |
| ☸️ **Kubernetes** | ⭐⭐⭐ Advanced | Production, scaling | K8s cluster + kubectl |

> 💡 **Recommendation for beginners:** Start with **Option 1** (Docker Compose). It's the simplest and works on any machine with Docker installed.

---

## 🐳 Option 1: Local Deployment with Docker Compose

This is the simplest deployment method. Everything runs on your local machine inside Docker containers.

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (v20+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2+)

### Step-by-Step Instructions

#### Step 1: Clone and Configure

```bash
# Clone the repository
git clone https://github.com/zaburdaev/my-devops-project.git
cd my-devops-project

# Create .env file from template
cp .env.example .env
```

#### Step 2: Build and Start

```bash
# Build the Docker image and start all 6 services
docker-compose up -d --build
```

> 💡 **What happens here?**
> 1. Docker builds the Flask app image using the multi-stage `Dockerfile`
> 2. Docker downloads images for PostgreSQL, Redis, Nginx, Prometheus, and Grafana
> 3. All 6 containers start and connect to the `app-network`
> 4. Health checks verify that services are running properly

#### Step 3: Verify

```bash
# Check that all services are running
docker-compose ps

# Check the app health
curl http://localhost:5000/health

# Expected response:
# {"status": "healthy", "timestamp": "...", "uptime_seconds": ...}
```

#### Step 4: Access Services

| Service | URL |
|---------|-----|
| 🏥 Dashboard | http://localhost |
| 📊 Grafana | http://localhost:3000 (credentials from `.env`) |
| 📈 Prometheus | http://localhost:9090 |
| 🔧 Flask API | http://localhost:5000 |

#### Step 5: Stop Services

```bash
# Stop all services (keeps data in volumes)
docker-compose down

# Stop and remove all data
docker-compose down -v
```

---

## ☁️ Option 2: AWS Deployment with Terraform

Terraform lets you create cloud infrastructure (servers, networks, security rules) using code. This option deploys the dashboard to an AWS EC2 instance.

> 💡 **What is Terraform?** Terraform is an "Infrastructure as Code" (IaC) tool. Instead of clicking buttons in the AWS console, you write configuration files that describe what infrastructure you want, and Terraform creates it for you. This is reproducible, version-controlled, and automated.

### Prerequisites

| Tool | Installation Link | Why You Need It |
|------|------------------|-----------------|
| **AWS Account** | [aws.amazon.com](https://aws.amazon.com/) | The cloud platform where the server will run |
| **AWS CLI** | [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | Command-line tool to interact with AWS |
| **Terraform** | [Install Terraform](https://developer.hashicorp.com/terraform/downloads) | Tool that creates the infrastructure |

### Step 1: Configure AWS Credentials

You need an AWS Access Key and Secret Key. These are like a username and password for programmatic access to AWS.

```bash
# Option A: Set environment variables
export AWS_ACCESS_KEY_ID="your-access-key-here"
export AWS_SECRET_ACCESS_KEY="your-secret-key-here"

# Option B: Use AWS CLI to configure
aws configure
# It will ask for:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., eu-central-1)
# - Default output format (json)
```

> ⚠️ **Security:** Never commit AWS credentials to Git! Use environment variables or the AWS CLI configuration.

### Step 2: Create an SSH Key Pair

You need an SSH key to connect to the EC2 instance after it's created.

```bash
# Create a key pair in AWS (or use the AWS Console)
aws ec2 create-key-pair --key-name my-devops-key --query 'KeyMaterial' --output text > my-devops-key.pem

# Set proper permissions (required by SSH)
chmod 400 my-devops-key.pem
```

### Step 3: Initialize Terraform

```bash
# Navigate to the terraform directory
cd terraform/

# Initialize Terraform (downloads AWS provider plugins)
terraform init
```

> 💡 **What does `terraform init` do?** It downloads the necessary plugins (called "providers") that Terraform needs to interact with AWS. You only need to run this once.

### Step 4: Preview the Changes

```bash
# See what Terraform will create (without actually creating anything)
terraform plan
```

This shows you exactly what resources Terraform will create:
- 1 EC2 instance (t2.micro — Free Tier eligible)
- 1 Security Group (opens ports 22, 80, 443, 3000, 9090)

> 💡 **Always review the plan** before applying! Make sure you're not accidentally creating expensive resources.

### Step 5: Create the Infrastructure

```bash
# Create the AWS resources
terraform apply

# Type "yes" when prompted to confirm
```

After a few minutes, Terraform will output:
```
Outputs:
instance_id = "i-0abc123def456..."
instance_public_ip = "18.197.7.122"
app_url = "http://18.197.7.122"
grafana_url = "http://18.197.7.122:3000"
prometheus_url = "http://18.197.7.122:9090"
```

### Step 6: Get the Server IP

```bash
# Show the outputs again
terraform output

# Get just the IP
terraform output instance_public_ip
```

### Step 7: Connect to the Server

```bash
# SSH into the EC2 instance
ssh -i my-devops-key.pem ec2-user@$(terraform output -raw instance_public_ip)
```

> 💡 The server already has Docker and Docker Compose installed (the Terraform user data script installs them automatically).

### Step 8: Deploy the Application on the Server

Once connected via SSH:

```bash
# Clone the repository on the server
git clone https://github.com/zaburdaev/my-devops-project.git
cd my-devops-project

# Configure environment
cp .env.example .env

# Start the application
docker-compose up -d --build
```

### Step 9: Access Your Cloud Application

Open your browser and visit:
- Dashboard: `http://<your-server-ip>`
- Grafana: `http://<your-server-ip>:3000`
- Prometheus: `http://<your-server-ip>:9090`

### Step 10: Destroy the Infrastructure (When Done)

```bash
# Remove all AWS resources to avoid charges
terraform destroy

# Type "yes" to confirm
```

> ⚠️ **Important:** Always destroy resources when you're done testing to avoid unexpected AWS charges!

---

## ☸️ Option 3: Kubernetes Deployment

Kubernetes (often abbreviated as K8s) is a container orchestration platform. It manages running containers at scale with features like auto-scaling, self-healing, and rolling updates.

> 💡 **What is Kubernetes?** Think of Docker Compose for the cloud, but much more powerful. It automatically restarts crashed containers, distributes traffic across multiple copies of your app, and handles rolling updates without downtime.

### Prerequisites

| Tool | Installation Link | Why You Need It |
|------|------------------|-----------------|
| **kubectl** | [Install kubectl](https://kubernetes.io/docs/tasks/tools/) | CLI tool to interact with Kubernetes |
| **Kubernetes cluster** | [Minikube](https://minikube.sigs.k8s.io/docs/start/) (local) or cloud | The platform where containers run |
| **Helm** | [Install Helm](https://helm.sh/docs/intro/install/) | *(Optional)* Package manager for K8s |

### Option A: Deploy with kubectl (Manifests)

#### Step 1: Apply All Manifests

```bash
# Apply all Kubernetes manifests in order
kubectl apply -f k8s/namespace.yaml     # Create the namespace first
kubectl apply -f k8s/configmap.yaml     # Application configuration
kubectl apply -f k8s/secret.yaml        # Sensitive data (passwords)
kubectl apply -f k8s/deployment.yaml    # Create the application pods
kubectl apply -f k8s/service.yaml       # Expose the application

# Or apply all at once
kubectl apply -f k8s/
```

> 💡 **What do these files do?**
> - `namespace.yaml` — Creates an isolated space called `health-dashboard` in the cluster
> - `configmap.yaml` — Stores non-secret config (ports, hostnames)
> - `secret.yaml` — Stores sensitive data (database passwords)
> - `deployment.yaml` — Tells K8s to run 2 copies of our Flask app
> - `service.yaml` — Creates a LoadBalancer to route traffic to the app

#### Step 2: Verify the Deployment

```bash
# Check all resources in the namespace
kubectl get all -n health-dashboard

# Check pods are running
kubectl get pods -n health-dashboard

# Check the service and get the external IP
kubectl get svc -n health-dashboard
```

Expected output:
```
NAME                                READY   STATUS    RESTARTS   AGE
pod/health-dashboard-xxx-abc        1/1     Running   0          60s
pod/health-dashboard-xxx-def        1/1     Running   0          60s

NAME                               TYPE           EXTERNAL-IP    PORT(S)
service/health-dashboard-service   LoadBalancer   <pending>      80:31234/TCP
```

#### Step 3: Access the Application

```bash
# For Minikube (local)
minikube service health-dashboard-service -n health-dashboard

# For cloud clusters, use the external IP from:
kubectl get svc -n health-dashboard
```

#### Step 4: Clean Up

```bash
# Remove all resources
kubectl delete -f k8s/
```

### Option B: Deploy with Helm Chart

Helm is a package manager for Kubernetes that makes deployments more configurable and repeatable.

#### Step 1: Install the Chart

```bash
# Install with default values
helm install health-dashboard ./k8s/helm/health-dashboard

# Or install with custom values
helm install health-dashboard ./k8s/helm/health-dashboard \
  --set replicaCount=3 \
  --set image.tag=latest
```

#### Step 2: Check the Status

```bash
# See the Helm release status
helm status health-dashboard

# List all Helm releases
helm list
```

#### Step 3: Update the Deployment

```bash
# Change values and upgrade
helm upgrade health-dashboard ./k8s/helm/health-dashboard \
  --set replicaCount=4
```

#### Step 4: Uninstall

```bash
helm uninstall health-dashboard
```

---

## ⚙️ Option 4: Ansible Automation

Ansible automates server configuration and application deployment. It connects to your server via SSH and runs tasks defined in a "playbook."

> 💡 **What is Ansible?** Think of it as a recipe for setting up a server. You write the steps (install Docker, copy files, start containers) in a YAML file, and Ansible executes them on any number of servers.

### Prerequisites

| Tool | Installation Link | Why You Need It |
|------|------------------|-----------------|
| **Ansible** | [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) | Automation tool |
| **SSH access** | SSH key pair | To connect to the target server |
| **Target server** | EC2 instance or any Linux server | Where the app will be deployed |

### Step 1: Configure the Inventory

Edit `ansible/inventory.ini` with your server details:

```ini
[webservers]
health-dashboard ansible_host=YOUR_SERVER_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/my-devops-key.pem

[webservers:vars]
ansible_python_interpreter=/usr/bin/python3
```

Replace `YOUR_SERVER_IP` with the actual IP address of your server (e.g., from Terraform output).

### Step 2: Test the Connection

```bash
# Ping the server to verify Ansible can connect
ansible -i ansible/inventory.ini webservers -m ping
```

You should see:
```
health-dashboard | SUCCESS => {
    "ping": "pong"
}
```

### Step 3: Run the Playbook

```bash
# Deploy the application
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

> 💡 **What does the Ansible playbook do?**
> 1. Updates system packages
> 2. Installs Docker and Docker Compose
> 3. Configures firewall (opens ports 80, 443, 22, 3000, 9090, 5000)
> 4. Copies project files to the server
> 5. Starts all Docker Compose services
> 6. Waits for the application to become healthy

### Step 4: Verify

After the playbook completes, access your application:
- Dashboard: `http://YOUR_SERVER_IP`
- Grafana: `http://YOUR_SERVER_IP:3000`
- Prometheus: `http://YOUR_SERVER_IP:9090`

---

## 📊 Quick Comparison

| Feature | Docker Compose | Terraform + SSH | Kubernetes | Ansible |
|---------|:--------------:|:---------------:|:----------:|:-------:|
| **Difficulty** | ⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Auto-scaling** | ❌ | ❌ | ✅ | ❌ |
| **Self-healing** | Basic | ❌ | ✅ | ❌ |
| **Cloud-ready** | ❌ | ✅ | ✅ | ✅ |
| **Multi-server** | ❌ | ❌ | ✅ | ✅ |
| **Cost** | Free | AWS costs | Cluster costs | Free |
| **Best for** | Development | Single cloud server | Production | Server setup |

---

## 📖 Related Documentation

- 🚀 [Getting Started](./GETTING_STARTED.md) — Initial setup guide
- 🏗️ [Architecture](./ARCHITECTURE.md) — System design overview
- 🔄 [CI/CD](./CI_CD.md) — Automated deployment pipeline
- 📊 [Monitoring](./MONITORING.md) — Monitoring your deployment

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>
