# 🚀 Deployment Summary — Health Dashboard

> **Redeployed:** 2026-04-23  
> **Author:** Vitalii Zaburdaiev | DevOpsUA6

---

## ✅ New AWS Infrastructure

| Resource | Details |
|----------|---------|
| **EC2 Instance** | t3.micro (Free Tier) |
| **Instance ID** | i-0c4b446783b0704eb |
| **Server IP** | 35.158.171.183 |
| **Region** | eu-central-1 (Frankfurt) |
| **OS** | Amazon Linux 2023 |
| **Disk** | 30 GB gp3 SSD |
| **Security Group** | health-dashboard-sg (22, 80, 443, 5000, 3000, 9090) |
| **SSH Key** | my-devops-key |

---

## 🔗 Access URLs

| Service | URL |
|---------|-----|
| **Health Dashboard** | http://35.158.171.183 |
| **Health endpoint** | http://35.158.171.183/health |
| **Grafana** | http://35.158.171.183:3000 |
| **Prometheus** | http://35.158.171.183:9090 |

---

## 🔑 GitHub Secrets (updated)

- `SERVER_HOST` = `35.158.171.183`
- `SERVER_USER` = `ec2-user`
- `SSH_PRIVATE_KEY` = updated with new Terraform key

---

## 📊 Monitoring Recovery

Implemented:
- Grafana auto-configuration script: `scripts/configure_grafana.sh`
- Recovery dashboard JSON: `grafana/dashboard.json`
- Loki persistence fix in `docker-compose.yml` + `monitoring/loki-config.yaml`

---

## 🧪 Verification Commands

```bash
curl http://35.158.171.183/health
curl http://35.158.171.183:9090/-/ready
curl http://35.158.171.183:3000/api/health
```

---

## 🗑️ Clean-up (to avoid AWS charges)

```bash
cd terraform/
terraform destroy -auto-approve
```
