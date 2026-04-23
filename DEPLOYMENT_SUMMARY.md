# 🚀 Deployment Summary — Health Dashboard

> **Updated:** 2026-04-23  
> **Author:** Vitalii Zaburdaiev | DevOpsUA6

---

## ✅ Current AWS Infrastructure

| Resource | Details |
|----------|---------|
| EC2 Instance ID | `i-0c4b446783b0704eb` |
| Region | `eu-central-1` |
| Instance Type | `t3.micro` (Free Tier target) |
| Elastic IP (Static) | `3.127.155.114` |
| Dynamic instance public IP | managed by AWS (may change, do not use in docs/secrets) |
| Security Group | `health-dashboard-sg` (22, 80, 443, 5000, 3000, 9090) |

> Public access must use **Elastic IP** (`3.127.155.114`).

---

## 🌐 Service Access

| Service | URL |
|---------|-----|
| Health Dashboard | http://3.127.155.114 |
| Health endpoint | http://3.127.155.114/health |
| Grafana | http://3.127.155.114:3000 |
| Prometheus | http://3.127.155.114:9090 |

---

## 🔑 Required GitHub Secrets

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SSH_PRIVATE_KEY`
- `SERVER_USER` = `ec2-user`
- `SERVER_HOST` = `3.127.155.114` (Elastic IP)

---

## ♻️ Infrastructure Recovery (GitHub Actions)

Workflow: `.github/workflows/infrastructure-recovery.yml`

What it does:
1. Runs `terraform apply` in `terraform/`
2. Gets `elastic_ip` from Terraform output
3. Updates `SERVER_HOST` secret
4. Connects to EC2 over SSH
5. Pulls latest `main` and runs `docker compose up -d --build`

Manual trigger:
- GitHub → **Actions** → **Infrastructure Recovery** → **Run workflow**

---

## 📊 Monitoring Auto-Provisioning

Implemented via filesystem provisioning at startup:

- `grafana/provisioning/datasources/datasources.yml`
- `grafana/provisioning/dashboards/dashboards.yml`
- `grafana/provisioning/dashboards/health-dashboard.json`

And in Compose:
- `docker-compose.yml` mounts `./grafana/provisioning:/etc/grafana/provisioning`

Prometheus scrape config:
- `monitoring/prometheus.yml` with jobs `flask-app` and `prometheus`

---

## 🧪 Quick Verification

```bash
curl http://3.127.155.114/health
curl http://3.127.155.114:9090/-/ready
curl http://3.127.155.114:3000/api/health
```

---

## 📚 Documentation Links

- [README.md](./README.md)
- [README_RU.md](./README_RU.md)
- [docs/MONITORING.md](./docs/MONITORING.md)
- [docs/AWS_DEPLOYMENT_RU.md](./docs/AWS_DEPLOYMENT_RU.md)
- [docs/INFRASTRUCTURE_RECOVERY_RU.md](./docs/INFRASTRUCTURE_RECOVERY_RU.md)

---
