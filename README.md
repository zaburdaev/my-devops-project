#  Health Monitoring Dashboard

[![CI/CD Pipeline](https://github.com/zaburdaev/my-devops-project/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/zaburdaev/my-devops-project/actions/workflows/ci-cd.yml)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://hub.docker.com/r/oskalibriya/health-dashboard)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5?logo=kubernetes&logoColor=white)](./k8s/)
[![Terraform](https://img.shields.io/badge/Terraform-AWS-7B42BC?logo=terraform)](./terraform/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](./requirements.txt)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

> **Author:** Vitalii Zaburdaiev  
> **Course:** DevOpsUA6  
> **Docker Hub:** [oskalibriya/health-dashboard](https://hub.docker.com/r/oskalibriya/health-dashboard)  
> **AWS:** Deployed at `3.127.155.114` ✅  
> **Description:** A full-stack DevOps project featuring a system health monitoring dashboard built with Flask, containerized with Docker, orchestrated with Kubernetes, provisioned with Terraform, configured with Ansible, and monitored with Prometheus + Grafana.

[Версия RU ](./README_RU.md)

---

## 📋 Table of Contents

- [About the Project](#-about-the-project)
- [Technology Stack](#-technology-stack)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Architecture](#-architecture)
- [Documentation](#-documentation)
- [API Endpoints](#-api-endpoints)
- [Monitoring](#-monitoring)
- [Testing](#-testing)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

---

## 🎯 About the Project

**Health Monitoring Dashboard** is a real-time system monitoring web application that demonstrates a complete DevOps lifecycle:

**development → testing → containerization → CI/CD → infrastructure provisioning → configuration management → deployment → monitoring**

### What It Does

The dashboard collects and displays live system metrics:

- 🖥️ **CPU Usage** — current processor load percentage
- 🧠 **Memory Usage** — RAM consumption metrics
- 💾 **Disk Usage** — storage utilization
- ⏱️ **Uptime** — application running time
- 🏥 **Health Status** — overall system health indicator

### Why It Exists

This project was created as a comprehensive DevOps course project (DevOpsUA6) to demonstrate proficiency in modern DevOps tools and practices. It serves as a practical example of how all the pieces of a DevOps pipeline fit together — from writing application code to monitoring it in production.

---

## 🛠️ Technology Stack

| Category | Technology | Purpose |
|----------|-----------|--------|
| 🐍 **Application** | Python 3.11 + Flask 3.1.3 | Web application & REST API |
| 🌐 **Web Server** | Gunicorn + Nginx | Production WSGI server & reverse proxy |
| 🗄️ **Database** | PostgreSQL 15 | Persistent metrics storage |
| ⚡ **Cache** | Redis 7 | Metrics caching (10s TTL) |
| 🐳 **Containerization** | Docker + Docker Compose | Multi-service orchestration (6 services) |
| 🔄 **CI/CD** | GitHub Actions | Automated testing, building, deploying |
| 🏗️ **IaC** | Terraform (AWS) | Infrastructure provisioning (EC2, SG) |
| ⚙️ **Config Management** | Ansible | Server configuration & app deployment |
| ☸️ **Orchestration** | Kubernetes + Helm | Container orchestration & scaling |
| 📈 **Monitoring** | Prometheus | Metrics collection & alerting |
| 📊 **Visualization** | Grafana 10.4.7 | Dashboards & data visualization |
| 📝 **Logging** | JSON logs (stdout) | Loki removed after optimization on t3.micro |

---

## ✨ Features

- ✅ **Real-time monitoring** — Live CPU, memory, and disk metrics
- ✅ **REST API** — JSON endpoints for system information and health checks
- ✅ **Prometheus metrics** — `/metrics` endpoint for metric scraping
- ✅ **Auto-provisioned Grafana** — Pre-built dashboards ready out of the box
- ✅ **Structured JSON logging** — exported to container stdout (Loki removed)
- ✅ **Multi-stage Docker build** — Optimized, secure container images
- ✅ **Non-root container** — Runs as `appuser` for security
- ✅ **Health checks** — Docker and Kubernetes readiness/liveness probes
- ✅ **Database persistence** — PostgreSQL stores metrics history
- ✅ **Redis caching** — Fast response times with 10-second TTL cache
- ✅ **CI/CD pipeline** — Automated test → build → deploy workflow
- ✅ **Infrastructure as Code** — Terraform provisions AWS resources
- ✅ **Configuration Management** — Ansible automates server setup
- ✅ **Kubernetes ready** — Manifests + Helm chart included
- ✅ **12 unit tests** — Comprehensive test coverage with pytest
- ✅ **Alert rules** — CPU, memory, and availability alerts

---

## 🚀 Quick Start

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/zaburdaev/my-devops-project.git
   cd my-devops-project
   ```

2. **Create environment file:**
   ```bash
   cp .env.example .env
   ```

3. **Start the application:**
   ```bash
   docker compose up --build
   ```

4. **Access the application:**
   - **Main App (via Nginx):** http://localhost
   - **Health Check:** http://localhost/health
   - **Grafana:** http://localhost:3000 (admin/admin)
   - **Prometheus:** http://localhost:9090
  
     
5. If have GRAFANA login issue 
   # Restart containers
docker compose down

docker compose up -d

and update password

### 🔧 Optional: Direct Flask Access (Port 5000)

By default, Flask app is only accessible via Nginx (port 80).

If you want direct access to Flask on port 5000:

```bash
# Copy the override template
cp docker-compose.override.yml.example docker-compose.override.yml

# Restart containers
docker compose down
docker compose up -d
```

**Note:** This requires port 5000 to be free on your machine.

### ⚠️ Port 5000 Already in Use?

If you get error: `bind: address already in use`

**Option 1:** Just use Nginx (recommended)
```bash
# Access via http://localhost instead of http://localhost:5000
```

**Option 2:** Find and stop the process using port 5000
```bash
# On macOS/Linux
lsof -ti:5000 | xargs kill -9

# On Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

**Option 3:** Don't use the override file (skip port 5000 exposure)

> 📖 **Need more details?** See the full [Getting Started Guide](./docs/GETTING_STARTED.md) and [Port Conflict Fix](./docs/PORT_CONFLICT_FIX.md).

---

## 📂 Project Structure

```
my-devops-project/
├── app/                          # 🐍 Flask application source code
│   ├── __init__.py               #    Python package init
│   ├── app.py                    #    Main application (routes, metrics, DB)
│   └── wsgi.py                   #    WSGI entry point for Gunicorn
├── tests/                        # 🧪 Unit tests (12 tests)
│   ├── conftest.py               #    Pytest fixtures & configuration
│   ├── test_app.py               #    Application endpoint tests
│   └── test_health.py            #    Health & system-info tests
├── nginx/                        # 🌐 Nginx reverse proxy
│   └── nginx.conf                #    Proxy configuration
├── monitoring/                   # 📊 Monitoring stack configuration
│   ├── prometheus.yml            #    Prometheus scrape config
│   └── alert_rules.yml           #    Alerting rules (CPU, Memory, Downtime)
├── grafana/                      # 📉 Grafana provisioning (auto-load)
│   └── provisioning/
│       ├── datasources/
│       │   └── datasources.yml   #    Prometheus datasource
│       └── dashboards/
│           ├── dashboards.yml    #    Dashboard provider config
│           └── health-dashboard.json
├── terraform/                    # 🏗️ Infrastructure as Code (AWS)
│   ├── main.tf                   #    EC2 instance + Security Group
│   ├── variables.tf              #    Input variables (region, type, key)
│   └── outputs.tf                #    Output values (IP, URLs)
├── ansible/                      # ⚙️ Configuration Management
│   ├── inventory.ini             #    Server inventory
│   ├── playbook.yml              #    Main playbook
│   └── roles/                    #    Ansible roles
│       ├── docker/               #    Docker installation role
│       └── app/                  #    App deployment role
├── k8s/                          # ☸️ Kubernetes manifests
│   ├── namespace.yaml            #    Namespace definition
│   ├── configmap.yaml            #    Application config
│   ├── secret.yaml               #    Sensitive data
│   ├── deployment.yaml           #    Pod deployment (2 replicas)
│   ├── service.yaml              #    LoadBalancer service
│   └── helm/                     #    Helm chart
│       └── health-dashboard/     #    Chart templates & values
├── .github/workflows/            # 🔄 CI/CD + Recovery Workflows
│   ├── ci-cd.yml                 #    Main pipeline (test/build/deploy)
│   └── infrastructure-recovery.yml #  Manual infra recovery workflow
├── docs/                         # 📚 Detailed documentation
│   ├── GETTING_STARTED.md        #    Beginner setup guide
│   ├── ARCHITECTURE.md           #    System architecture
│   ├── DEPLOYMENT.md             #    Deployment options guide
│   ├── CI_CD.md                  #    CI/CD pipeline docs
│   ├── MONITORING.md             #    Monitoring & Grafana guide
│   ├── TESTING.md                #    Testing guide
│   └── PROJECT_CHECKLIST.md      #    Project submission checklist
├── Dockerfile                    # 🐳 Multi-stage Docker build
├── docker-compose.yml            # 🐳 Full stack (6 services)
├── Makefile                      # 🔧 Automation shortcuts
├── requirements.txt              # 📦 Python dependencies
├── .env.example                  # 🔐 Environment variable template
├── .gitignore                    # 🚫 Git ignore rules
├── CONTRIBUTING.md               # 🤝 Contribution guidelines
├── LICENSE                       # 📄 MIT License
└── README.md                     # 📖 This file
```

---

## 🏗️ Architecture

```
┌─────────────┐     ┌─────────────┐     ┌──────────────────┐
│   Browser    │────▶│    Nginx    │────▶│   Flask App      │
│   (User)     │     │   (port 80) │     │   (port 5000)    │
└─────────────┘     └─────────────┘     └──────┬───────────┘
                                               │
                          ┌────────────────────┼────────────────────┐
                          │                    │                    │
                    ┌─────▼─────┐      ┌──────▼──────┐    ┌──────▼──────┐
                    │ PostgreSQL │      │    Redis     │    │ Prometheus  │
                    │ (port 5432)│      │ (port 6379) │    │ (port 9090) │
                    └───────────┘      └─────────────┘    └──────┬──────┘
                                                                  │
                                                           ┌──────▼──────┐
                                                           │   Grafana   │
                                                           │ (port 3000) │
                                                           └─────────────┘
```

> 📖 For detailed architecture documentation, see [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md).

---

## 📚 Documentation

This project includes comprehensive documentation for every aspect:

| Document | Description |
|----------|-------------|
| 📖 [Getting Started](./docs/GETTING_STARTED.md) | Step-by-step beginner setup guide |
| 🏗️ [Architecture](./docs/ARCHITECTURE.md) | System design & component overview |
| 🚀 [Deployment](./docs/DEPLOYMENT.md) | All deployment options (Docker, AWS, K8s, Ansible) |
| 🔄 [CI/CD](./docs/CI_CD.md) | GitHub Actions pipeline explanation |
| 📊 [Monitoring](./docs/MONITORING.md) | Prometheus & Grafana guide (Loki removed) |
| 🧪 [Testing](./docs/TESTING.md) | Testing strategy & how to run tests |
| ✅ [Project Checklist](./docs/PROJECT_CHECKLIST.md) | Submission checklist (240 points) |
| 🤝 [Contributing](./CONTRIBUTING.md) | How to contribute to this project |

### Ru Documentation

| Document | Description |
|----------|-------------|
| 📘 [Руководство для начинающих](./docs/BEGINNER_GUIDE_RU.md) | Complete beginner guide (Russian) |
| 🎬 [Сценарий демонстрации](./docs/DEMO_SCRIPT_RU.md) | Demo script for project defense (Russian) |
| ☁️ [AWS деплой](./docs/AWS_DEPLOYMENT_RU.md) | AWS deployment guide (Russian) |
| ♻️ [Recovery runbook RU](./docs/INFRASTRUCTURE_RECOVERY_RU.md) | Infrastructure recovery guide (Russian) |
| 🚀 [Deployment Summary](./DEPLOYMENT_SUMMARY.md) | Deployed infrastructure summary |
| 🔒 [Security Audit](./SECURITY_AUDIT.md) | Security audit results |
| 📋 [Documentation Status](./DOCUMENTATION_STATUS.md) | Full documentation status report |

---

## 📊 Presentations

Project presentations are available in PDF format:
- [English Version](presentations/DevOps_Project_Presentation_EN.pdf)
- [Russian Version](presentations/DevOps_Project_Presentation_RU.pdf)

---

## 🌐 Live Deployment

The application is **deployed and running** on AWS:

| Service | URL |
|---------|-----|
| **Health Dashboard** | http://3.127.155.114 |
| **Grafana** | http://3.127.155.114:3000 |
| **Prometheus** | http://3.127.155.114:9090 |

### Elastic IP (Static)

Infrastructure now uses an **AWS Elastic IP** (`3.127.155.114`), so public access IP remains stable even if EC2 is recreated.

You can always get the current static IP from Terraform:

```bash
cd terraform
terraform output -raw elastic_ip
```

### Infrastructure Recovery (GitHub Actions)

If server resources are deleted or become inconsistent:

1. Open **GitHub → Actions → Infrastructure Recovery**
2. Click **Run workflow**
3. Workflow recreates/repairs infrastructure via Terraform
4. Reads `elastic_ip` output and updates `SERVER_HOST`
5. Re-deploys application via SSH

Workflow file: [`.github/workflows/infrastructure-recovery.yml`](./.github/workflows/infrastructure-recovery.yml)

> 📖 See [DEPLOYMENT_SUMMARY.md](./DEPLOYMENT_SUMMARY.md), [docs/AWS_DEPLOYMENT_RU.md](./docs/AWS_DEPLOYMENT_RU.md), and [docs/INFRASTRUCTURE_RECOVERY_RU.md](./docs/INFRASTRUCTURE_RECOVERY_RU.md) for details.

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | HTML Dashboard UI |
| `GET` | `/health` | Health check (JSON) |
| `GET` | `/metrics` | Prometheus metrics |
| `GET` | `/api/system-info` | Detailed system info (JSON) |

### Example: `/health`

```json
{
  "status": "healthy",
  "timestamp": "2026-04-12T16:00:00Z",
  "uptime_seconds": 3600.5
}
```

### Example: `/api/system-info`

```json
{
  "hostname": "health-dashboard",
  "platform": "Linux",
  "cpu_percent": 12.5,
  "memory": { "total_gb": 7.77, "used_percent": 45.2 },
  "disk": { "total_gb": 19.52, "used_percent": 32.1 },
  "uptime_seconds": 3600.5,
  "timestamp": "2026-04-12T16:00:00Z"
}
```

---

## 📊 Monitoring

The project includes a full monitoring stack:

- **Prometheus** (`:9090`) — Collects metrics from `/metrics` every 60 seconds
- **Grafana** (`:3000`, version 10.4.7) — Pre-configured dashboard with CPU, memory, disk charts
- **Structured logs** — available via container stdout (`docker compose logs`), Loki removed
- **Alert Rules** — CPU > 80%, Memory > 85%, App down alerts

> 📖 See [docs/MONITORING.md](./docs/MONITORING.md) for the full monitoring guide.

---

## 🧪 Testing

The project includes 12 unit tests covering all API endpoints:

```bash
# Run tests locally
make test

# Run tests in Docker
make test-docker

# Run linting
make lint
```

> 📖 See [docs/TESTING.md](./docs/TESTING.md) for the full testing guide.

---

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline (`ci-cd.yml`) runs on every push/PR to `main`:

1. **🧪 Test** → Install dependencies, run pytest (12 tests), run flake8 linting
2. **🐳 Build** → Build Docker image, push to Docker Hub (on main branch only)
3. **🚀 Deploy** → SSH into server, pull latest image, restart services

> 📖 See [docs/CI_CD.md](./docs/CI_CD.md) for the full CI/CD guide.

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](./CONTRIBUTING.md) before submitting a pull request.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'feat: add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](./LICENSE) file for details.

---

## 📬 Contact

- **Author:** Vitalii Zaburdaiev
- **Course:** DevOpsUA6
- **GitHub:** [github.com/zaburdaev](https://github.com/zaburdaev)
- **Project Link:** [github.com/zaburdaev/my-devops-project](https://github.com/zaburdaev/my-devops-project)

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>
