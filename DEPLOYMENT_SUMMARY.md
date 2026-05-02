# 🚀 Deployment Summary — Health Dashboard

> **Updated:** 2026-04-23  
> **Status:** Final setup completed

## ✅ Current AWS Infrastructure

| Resource | Details |
|---|---|
| EC2 Instance ID | `i-0c4b446783b0704eb` |
| Region | `eu-central-1` |
| Instance Type | `t3.micro` |
| Elastic IP (Static) | `18.197.7.122` |
| Security Group | `health-dashboard-sg` (22, 80, 443, 5000, 3000, 9090) |

> Use **Elastic IP** in docs/secrets and service links. This IP stays stable while the EIP resource remains allocated.

## 🌐 Current Service URLs

- Health Dashboard: http://18.197.7.122
- Flask health endpoint: http://18.197.7.122:5000/health
- Grafana: http://18.197.7.122:3000
- Prometheus: http://18.197.7.122:9090

## 🔐 GitHub Secrets (Required)

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SSH_PRIVATE_KEY`
- `SERVER_USER=ec2-user`
- `SERVER_HOST=18.197.7.122`

## ♻️ Infrastructure Recovery Workflow

Workflow file: `.github/workflows/infrastructure-recovery.yml`

Manual run:
1. GitHub → **Actions**
2. Select **Infrastructure Recovery**
3. Click **Run workflow**

The workflow will:
1. run `terraform init/apply`
2. read `terraform output -raw elastic_ip`
3. update `SERVER_HOST`
4. SSH into server and redeploy Docker stack

## 📊 Grafana Auto-Provisioning

Provisioning source (mounted in Compose):
- `./monitoring/grafana/provisioning:/etc/grafana/provisioning`

Verified outcome:
- Data source created automatically: **Prometheus** (Loki removed)
- Dashboards auto-loaded from provisioning files

## 🧪 Verification

Executed `./verify_services.sh` successfully:

- ✅ `http://18.197.7.122:5000/health`
- ✅ `http://18.197.7.122:9090/-/healthy`
- ✅ `http://18.197.7.122:3000/api/health`

## 📄 Related Summary

See full final report: `FINAL_SETUP_SUMMARY.md`
