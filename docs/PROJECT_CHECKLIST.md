# ✅ Project Submission Checklist

This checklist helps you verify that the **Health Monitoring Dashboard** project is complete and ready for submission. It maps each grading criterion to the specific files and demonstrations in the project.

> **Course:** DevOpsUA6  
> **Total Points:** 240  
> **Author:** Vitalii Zaburdaiev

---

## 📋 Table of Contents

- [Grading Criteria Breakdown](#-grading-criteria-breakdown)
- [Where to Find Each Component](#-where-to-find-each-component)
- [How to Demonstrate Each Technology](#-how-to-demonstrate-each-technology)
- [Pre-Submission Checklist](#-pre-submission-checklist)
- [What to Show the Instructor](#-what-to-show-the-instructor)
- [Common Mistakes to Avoid](#-common-mistakes-to-avoid)

---

## 📊 Grading Criteria Breakdown

| # | Category | Points | Status |
|---|----------|:------:|:------:|
| 1 | **Docker & Docker Compose** | 40 | ✅ |
| 2 | **CI/CD (GitHub Actions)** | 40 | ✅ |
| 3 | **Terraform (Infrastructure as Code)** | 30 | ✅ |
| 4 | **Kubernetes** | 30 | ✅ |
| 5 | **Ansible** | 30 | ✅ |
| 6 | **Monitoring (Prometheus + Grafana)** | 30 | ✅ |
| 7 | **Application & Testing** | 20 | ✅ |
| 8 | **Documentation & Presentation** | 20 | ✅ |
| | **TOTAL** | **240** | ✅ |

---

## 📂 Where to Find Each Component

### 1. 🐳 Docker & Docker Compose (40 points)

| Criterion | File/Location | What to Look For |
|-----------|--------------|-----------------|
| Dockerfile exists | `Dockerfile` | Multi-stage build, non-root user |
| Docker Compose config | `docker-compose.yml` | 7 services defined |
| Multiple services | `docker-compose.yml` | app, postgres, redis, nginx, prometheus, grafana, loki |
| Health checks | `docker-compose.yml` | `healthcheck` sections for app, postgres, redis |
| Volumes for persistence | `docker-compose.yml` | `postgres_data`, `redis_data`, `grafana_data` volumes |
| Network configuration | `docker-compose.yml` | `app-network` bridge network |
| Environment variables | `.env.example` | Template with all variables |
| Multi-stage build | `Dockerfile` | `FROM python:3.11-slim AS builder` + production stage |

**How to demonstrate:**
```bash
# Show running containers
docker-compose ps

# Show all 7 services are healthy
docker-compose up -d --build
curl http://localhost:5000/health
```

### 2. 🔄 CI/CD — GitHub Actions (40 points)

| Criterion | File/Location | What to Look For |
|-----------|--------------|-----------------|
| Workflow file exists | `.github/workflows/ci-cd.yml` | Complete pipeline definition |
| Test stage | `ci-cd.yml` → `test` job | pytest + flake8 |
| Build stage | `ci-cd.yml` → `build` job | Docker build + push to Docker Hub |
| Deploy stage | `ci-cd.yml` → `deploy` job | SSH deploy to server |
| Triggers configured | `ci-cd.yml` → `on:` | push to main + pull_request |
| Secrets configured | GitHub Settings → Secrets | DOCKER_HUB_TOKEN, etc. |

**How to demonstrate:**
1. Show the workflow file on GitHub
2. Go to **Actions** tab → show workflow runs
3. Click on a successful run → show Test, Build stages
4. Show Docker Hub image: [hub.docker.com/r/oskalibriya/health-dashboard](https://hub.docker.com/r/oskalibriya/health-dashboard)

### 3. 🏗️ Terraform (30 points)

| Criterion | File/Location | What to Look For |
|-----------|--------------|-----------------|
| Main configuration | `terraform/main.tf` | EC2 instance + Security Group |
| Variables defined | `terraform/variables.tf` | Region, instance type, key name |
| Outputs defined | `terraform/outputs.tf` | IP, DNS, URLs |
| AWS provider | `terraform/main.tf` | `provider "aws"` block |
| Security group rules | `terraform/main.tf` | Ports 22, 80, 443, 3000, 9090 |
| User data script | `terraform/main.tf` | Docker + Docker Compose installation |

**How to demonstrate:**
```bash
cd terraform/
terraform init
terraform plan    # Show what would be created
# terraform apply  # Actually create (costs money!)
```

### 4. ☸️ Kubernetes (30 points)

| Criterion | File/Location | What to Look For |
|-----------|--------------|-----------------|
| Namespace | `k8s/namespace.yaml` | `health-dashboard` namespace |
| ConfigMap | `k8s/configmap.yaml` | Non-sensitive configuration |
| Secret | `k8s/secret.yaml` | Sensitive data (base64 encoded) |
| Deployment | `k8s/deployment.yaml` | 2 replicas, probes, resources |
| Service | `k8s/service.yaml` | LoadBalancer type |
| Helm chart | `k8s/helm/health-dashboard/` | Chart.yaml, values.yaml, templates/ |

**How to demonstrate:**
```bash
# Show manifest files
cat k8s/deployment.yaml

# If you have a cluster (minikube):
kubectl apply -f k8s/
kubectl get all -n health-dashboard

# Helm:
helm install health-dashboard ./k8s/helm/health-dashboard
helm list
```

### 5. ⚙️ Ansible (30 points)

| Criterion | File/Location | What to Look For |
|-----------|--------------|-----------------|
| Inventory file | `ansible/inventory.ini` | Server definition |
| Playbook | `ansible/playbook.yml` | Tasks + roles |
| Docker role | `ansible/roles/docker/tasks/main.yml` | Docker installation tasks |
| App role | `ansible/roles/app/tasks/main.yml` | Deployment tasks |
| Firewall configuration | `ansible/playbook.yml` | firewalld rules |

**How to demonstrate:**
```bash
# Show the playbook structure
cat ansible/playbook.yml

# If you have a server:
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

### 6. 📊 Monitoring (30 points)

| Criterion | File/Location | What to Look For |
|-----------|--------------|-----------------|
| Prometheus config | `monitoring/prometheus.yml` | Scrape targets configured |
| Alert rules | `monitoring/alert_rules.yml` | CPU, memory, downtime alerts |
| Grafana datasources | `monitoring/grafana/provisioning/datasources/` | Prometheus + Loki auto-configured |
| Grafana dashboard | `monitoring/grafana/dashboards/health-dashboard.json` | 5 panels |
| Dashboard provisioning | `monitoring/grafana/provisioning/dashboards/` | Auto-load config |
| Loki configuration | `monitoring/loki-config.yaml` | Log aggregation setup |
| App exposes metrics | `app/app.py` | `/metrics` endpoint |

**How to demonstrate:**
1. Open Grafana at http://localhost:3000 (admin/admin)
2. Show the Health Dashboard with live metrics
3. Open Prometheus at http://localhost:9090 → Status → Targets (all UP)
4. Show `/metrics` endpoint: `curl http://localhost:5000/metrics`

### 7. 🐍 Application & Testing (20 points)

| Criterion | File/Location | What to Look For |
|-----------|--------------|-----------------|
| Flask application | `app/app.py` | Routes, metrics, DB integration |
| REST API endpoints | `app/app.py` | /health, /api/system-info, /metrics |
| Unit tests | `tests/test_app.py`, `tests/test_health.py` | 12 tests |
| Test fixtures | `tests/conftest.py` | app + client fixtures |
| Requirements file | `requirements.txt` | All dependencies pinned |

**How to demonstrate:**
```bash
# Run tests
pytest tests/ -v

# Show 12 tests passing
# Show API responses
curl http://localhost:5000/health
curl http://localhost:5000/api/system-info
```

### 8. 📖 Documentation & Presentation (20 points)

| Criterion | File/Location |
|-----------|--------------|
| README.md | `README.md` |
| Getting Started guide | `docs/GETTING_STARTED.md` |
| Architecture docs | `docs/ARCHITECTURE.md` |
| Deployment guide | `docs/DEPLOYMENT.md` |
| CI/CD docs | `docs/CI_CD.md` |
| Monitoring guide | `docs/MONITORING.md` |
| Testing docs | `docs/TESTING.md` |
| Contributing guide | `CONTRIBUTING.md` |
| License | `LICENSE` |
| Makefile | `Makefile` |

---

## 📋 Pre-Submission Checklist

Run through this checklist before submitting:

### Code & Configuration

- [ ] All files are committed to Git
- [ ] `.env.example` exists (but NOT `.env`)
- [ ] `Dockerfile` builds successfully
- [ ] `docker-compose.yml` starts all 7 services
- [ ] All 12 tests pass (`pytest tests/ -v`)
- [ ] Flake8 linting passes (`make lint`)

### GitHub

- [ ] Repository is accessible at github.com/zaburdaev/my-devops-project
- [ ] CI/CD pipeline runs (Actions tab shows workflow runs)
- [ ] GitHub Secrets are configured
- [ ] README.md is visible on the repository page

### Docker

- [ ] Image is on Docker Hub: `oskalibriya/health-dashboard`
- [ ] `docker-compose up -d --build` starts all services
- [ ] All containers show "healthy" or "Up" status
- [ ] Dashboard is accessible at http://localhost

### Monitoring

- [ ] Grafana dashboard shows live data at http://localhost:3000
- [ ] Prometheus targets are all UP at http://localhost:9090/targets
- [ ] `/metrics` endpoint returns Prometheus-format data

### Infrastructure

- [ ] Terraform files are valid (`terraform validate` in `terraform/`)
- [ ] Kubernetes manifests are valid
- [ ] Ansible playbook is syntactically correct
- [ ] Helm chart is valid

---

## 🎤 What to Show the Instructor

### Demo Script (10-15 minutes)

1. **Show the GitHub repository** (README, file structure, Actions tab)
2. **Clone and run locally:**
   ```bash
   git clone https://github.com/zaburdaev/my-devops-project.git
   cd my-devops-project
   cp .env.example .env
   docker-compose up -d --build
   ```
3. **Show the dashboard:** Open http://localhost
4. **Show API endpoints:**
   ```bash
   curl http://localhost:5000/health | python3 -m json.tool
   curl http://localhost:5000/api/system-info | python3 -m json.tool
   ```
5. **Show Grafana:** Open http://localhost:3000, navigate to Health Dashboard
6. **Show Prometheus:** Open http://localhost:9090, go to Targets
7. **Run tests:** `pytest tests/ -v` (all 12 pass)
8. **Show CI/CD:** Open GitHub Actions tab, show a successful run
9. **Show Terraform:** `cat terraform/main.tf`, explain the resources
10. **Show Kubernetes:** `cat k8s/deployment.yaml`, explain the manifest
11. **Show Ansible:** `cat ansible/playbook.yml`, explain the roles
12. **Show Docker Hub:** Open hub.docker.com/r/oskalibriya/health-dashboard

---

## ⚠️ Common Mistakes to Avoid

| Mistake | How to Avoid |
|---------|-------------|
| Committing `.env` with real passwords | Check `.gitignore` includes `.env` |
| Docker images not built | Run `docker-compose up --build` |
| Tests fail due to missing dependencies | Run `pip install -r requirements.txt` |
| Grafana shows no data | Wait 60 seconds after starting, check Prometheus targets |
| Terraform state committed to Git | `.gitignore` should include `*.tfstate` |
| Kubernetes secrets in plain text | Use base64 encoding in `secret.yaml` |
| CI/CD pipeline skipped | Make sure you're pushing to `main` branch |
| Port conflicts | Stop other services using ports 80, 3000, 5000, 9090 |
| Forgetting to explain WHY | Always explain the purpose, not just the commands |
| Not showing live demo | Practice the demo script at least once before presenting |

---

## 📖 Related Documentation

- 📖 [README](../README.md) — Project overview
- 🚀 [Getting Started](./GETTING_STARTED.md) — Setup guide
- 🏗️ [Architecture](./ARCHITECTURE.md) — System design
- 🚀 [Deployment](./DEPLOYMENT.md) — Deployment options
- 🔄 [CI/CD](./CI_CD.md) — Pipeline docs
- 📊 [Monitoring](./MONITORING.md) — Monitoring guide
- 🧪 [Testing](./TESTING.md) — Testing guide

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>
