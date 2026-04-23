# 📌 Recovery & Access Summary

> Updated: 2026-04-23

## Static Elastic IP

- **Elastic IP:** `3.127.155.114`
- Terraform output command:

```bash
cd terraform
terraform output -raw elastic_ip
```

## Service Access

- Health Dashboard: http://3.127.155.114
- Grafana: http://3.127.155.114:3000
- Prometheus: http://3.127.155.114:9090

## Infrastructure Recovery (Manual Trigger)

GitHub Actions workflow: `.github/workflows/infrastructure-recovery.yml`

How to run:
1. GitHub → **Actions**
2. Select **Infrastructure Recovery**
3. Click **Run workflow**

What it does:
1. `terraform apply` for infra restore
2. Reads `elastic_ip`
3. Updates `SERVER_HOST`
4. SSH deploys latest `main`

## Main Documentation Links

- [README.md](./README.md)
- [README_RU.md](./README_RU.md)
- [DEPLOYMENT_SUMMARY.md](./DEPLOYMENT_SUMMARY.md)
- [DOCUMENTATION_STATUS.md](./DOCUMENTATION_STATUS.md)
- [docs/MONITORING.md](./docs/MONITORING.md)
- [docs/CI_CD.md](./docs/CI_CD.md)
- [docs/AWS_DEPLOYMENT_RU.md](./docs/AWS_DEPLOYMENT_RU.md)
- [docs/INFRASTRUCTURE_RECOVERY_RU.md](./docs/INFRASTRUCTURE_RECOVERY_RU.md)
