# 🚀 Deployment Summary — Health Dashboard

> **Deployed:** 2026-04-12  
> **Author:** Vitalii Zaburdaiev | DevOpsUA6

---

## ✅ Deployed Infrastructure

| Resource | Details |
|----------|---------|
| **EC2 Instance** | t3.micro (Free Tier) |
| **Instance ID** | i-003f45cb781d8f182 |
| **Server IP** | 54.93.95.178 |
| **Region** | eu-central-1 (Frankfurt) |
| **OS** | Amazon Linux 2023 |
| **Disk** | 30 GB gp3 SSD |
| **Security Group** | health-dashboard-sg |
| **SSH Key** | my-devops-key |

---

## 🔗 Access URLs

| Service | URL |
|---------|-----|
| **Health Dashboard** | http://54.93.95.178 |
| **Grafana** | http://54.93.95.178:3000 |
| **Prometheus** | http://54.93.95.178:9090 |

---

## 🔌 How to Access the Server

```bash
# SSH into the server
ssh -i my-devops-key.pem ec2-user@54.93.95.178

# Or use the Terraform output
cd terraform/
terraform output ssh_command
```

---

## 🔑 GitHub Secrets Configured

| Secret | Status | Description |
|--------|--------|-------------|
| `AWS_ACCESS_KEY_ID` | ✅ Set | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | ✅ Set | AWS secret key |
| `DOCKER_HUB_TOKEN` | ✅ Set | Docker Hub auth token |
| `SERVER_HOST` | ✅ Set | Server IP (54.93.95.178) |
| `SERVER_USER` | ✅ Set | SSH user (ec2-user) |
| `SSH_PRIVATE_KEY` | ✅ Set | SSH private key for deployment |

---

## 📋 Next Steps

1. **Deploy the application** using Ansible or manual SSH:
   ```bash
   cd ansible/
   # Update inventory.ini with the server IP
   ansible-playbook -i inventory.ini playbook.yml
   ```

2. **Verify application** is running:
   ```bash
   curl http://54.93.95.178/health
   ```

3. **Push to GitHub** to trigger CI/CD pipeline:
   ```bash
   git push origin main
   ```

4. **Monitor** via Grafana at http://54.93.95.178:3000

---

## ⚠️ Important Notes

- **Cost:** EC2 t3.micro is Free Tier eligible (750 hours/month for 12 months)
- **Delete when done:** Run `terraform destroy` to avoid charges
- **SSH key:** The private key (`my-devops-key.pem`) is stored locally and in GitHub Secrets
- **Security:** Do NOT commit `my-devops-key.pem` or `.tfstate` files to Git
- **Terraform state:** Stored locally in `terraform/terraform.tfstate` — do not delete unless you want to lose track of resources

---

## 🗑️ How to Tear Down

```bash
cd terraform/
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="eu-central-1"
terraform destroy -auto-approve
```
