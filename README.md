# 🏥 Health Monitoring Dashboard

[![CI/CD Pipeline](https://github.com/zaburdaev/my-devops-project/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/zaburdaev/my-devops-project/actions/workflows/ci-cd.yml)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://hub.docker.com/r/oskalibriya/health-dashboard)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5?logo=kubernetes&logoColor=white)](./k8s/)
[![Terraform](https://img.shields.io/badge/Terraform-AWS-7B42BC?logo=terraform)](./terraform/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](./requirements.txt)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

> **Author:** Vitalii Zaburdaiev  
> **Course:** DevOpsUA6  
> **Docker Hub:** [oskalibriya/health-dashboard](https://hub.docker.com/r/oskalibriya/health-dashboard)  
> **AWS:** Deployed at `54.93.95.178` ✅  
> **Description:** A full-stack DevOps project featuring a system health monitoring dashboard built with Flask, containerized with Docker, orchestrated with Kubernetes, provisioned with Terraform, configured with Ansible, and monitored with Prometheus + Grafana + Loki.

🇷🇺 [Версия на русском](./README_RU.md)

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
| 🐍 **Application** | Python 3.11 + Flask | Web application & REST API |
| 🌐 **Web Server** | Gunicorn + Nginx | Production WSGI server & reverse proxy |
| 🗄️ **Database** | PostgreSQL 15 | Persistent metrics storage |
| ⚡ **Cache** | Redis 7 | Metrics caching (10s TTL) |
| 🐳 **Containerization** | Docker + Docker Compose | Multi-service orchestration (7 services) |
| 🔄 **CI/CD** | GitHub Actions | Automated testing, building, deploying |
| 🏗️ **IaC** | Terraform (AWS) | Infrastructure provisioning (EC2, SG) |
| ⚙️ **Config Management** | Ansible | Server configuration & app deployment |
| ☸️ **Orchestration** | Kubernetes + Helm | Container orchestration & scaling |
| 📈 **Monitoring** | Prometheus | Metrics collection & alerting |
| 📊 **Visualization** | Grafana | Dashboards & data visualization |
| 📝 **Logging** | Loki | Log aggregation & querying |

---

## ✨ Features

- ✅ **Real-time monitoring** — Live CPU, memory, and disk metrics
- ✅ **REST API** — JSON endpoints for system information and health checks
- ✅ **Prometheus metrics** — `/metrics` endpoint for metric scraping
- ✅ **Auto-provisioned Grafana** — Pre-built dashboards ready out of the box
- ✅ **Structured JSON logging** — Loki-compatible log format
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

### Prerequisites

You only need these two tools installed on your machine:

- [Docker](https://docs.docker.com/get-docker/) (v20+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2+)

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/zaburdaev/my-devops-project.git
cd my-devops-project
```

### 2️⃣ Configure Environment

```bash
# Copy the example environment file
cp .env.example .env

# (Optional) Edit .env with your own values — defaults work for local development
```

### 3️⃣ Build and Run

```bash
# Option A: Using Make (recommended)
make deploy

# Option B: Using Docker Compose directly
docker-compose up -d --build
```

### 4️⃣ Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| 🏥 Dashboard | http://localhost | — |
| 📊 Grafana | http://localhost:3000 | admin / admin |
| 📈 Prometheus | http://localhost:9090 | — |
| 🔧 Flask API | http://localhost:5000 | — |

### 5️⃣ Stop Services

```bash
make down
# or
docker-compose down
```

> 📖 **Need more details?** See the full [Getting Started Guide](./docs/GETTING_STARTED.md).

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
│   ├── alert_rules.yml           #    Alerting rules (CPU, Memory, Downtime)
│   ├── loki-config.yaml          #    Loki log aggregation config
│   └── grafana/                  #    Grafana provisioning
│       ├── dashboards/           #    Pre-built dashboard JSON
│       └── provisioning/         #    Auto-provisioning for datasources
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
├── .github/workflows/            # 🔄 CI/CD Pipeline
│   └── ci-cd.yml                 #    GitHub Actions workflow
├── docs/                         # 📚 Detailed documentation
│   ├── GETTING_STARTED.md        #    Beginner setup guide
│   ├── ARCHITECTURE.md           #    System architecture
│   ├── DEPLOYMENT.md             #    Deployment options guide
│   ├── CI_CD.md                  #    CI/CD pipeline docs
│   ├── MONITORING.md             #    Monitoring & Grafana guide
│   ├── TESTING.md                #    Testing guide
│   └── PROJECT_CHECKLIST.md      #    Project submission checklist
├── Dockerfile                    # 🐳 Multi-stage Docker build
├── docker-compose.yml            # 🐳 Full stack (7 services)
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
                                                           └──────┬──────┘
                                                                  │
                                                           ┌──────▼──────┐
                                                           │    Loki     │
                                                           │ (port 3100) │
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
| 📊 [Monitoring](./docs/MONITORING.md) | Prometheus, Grafana & Loki guide |
| 🧪 [Testing](./docs/TESTING.md) | Testing strategy & how to run tests |
| ✅ [Project Checklist](./docs/PROJECT_CHECKLIST.md) | Submission checklist (240 points) |
| 🤝 [Contributing](./CONTRIBUTING.md) | How to contribute to this project |

### 🇷🇺 Russian Documentation

| Document | Description |
|----------|-------------|
| 📘 [Руководство для начинающих](./docs/BEGINNER_GUIDE_RU.md) | Complete beginner guide (Russian) |
| 🎬 [Сценарий демонстрации](./docs/DEMO_SCRIPT_RU.md) | Demo script for project defense (Russian) |
| ☁️ [AWS деплой](./docs/AWS_DEPLOYMENT_RU.md) | AWS deployment guide (Russian) |
| 🚀 [Deployment Summary](./DEPLOYMENT_SUMMARY.md) | Deployed infrastructure summary |
| 🔒 [Security Audit](./SECURITY_AUDIT.md) | Security audit results |
| 📋 [Documentation Status](./DOCUMENTATION_STATUS.md) | Full documentation status report |

---

## 🌐 Live Deployment

The application is **deployed and running** on AWS:

| Service | URL |
|---------|-----|
| **Health Dashboard** | http://54.93.95.178 |
| **Grafana** | http://54.93.95.178:3000 |
| **Prometheus** | http://54.93.95.178:9090 |

> 📖 See [DEPLOYMENT_SUMMARY.md](./DEPLOYMENT_SUMMARY.md) and [docs/AWS_DEPLOYMENT_RU.md](./docs/AWS_DEPLOYMENT_RU.md) for details.

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

- **Prometheus** (`:9090`) — Collects metrics from `/metrics` every 10 seconds
- **Grafana** (`:3000`) — Pre-configured dashboard with CPU, memory, disk charts
- **Loki** (`:3100`) — Aggregates structured JSON logs from the Flask app
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
