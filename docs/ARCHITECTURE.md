# 🏗️ Architecture Documentation

This document describes the current architecture of **Health Monitoring Dashboard** after optimization.

---

## 📋 Table of Contents

- [System Overview](#-system-overview)
- [Architecture Diagram](#-architecture-diagram)
- [Service Responsibilities](#-service-responsibilities)
- [Data Flow](#-data-flow)
- [Network and Ports](#-network-and-ports)
- [Security Notes](#-security-notes)
- [Scaling Notes](#-scaling-notes)

---

## 🌐 System Overview

The current Docker Compose stack runs **6 services**:

| # | Service | Technology | Role |
|---|---------|-----------|------|
| 1 | `app` | Flask 3.1.3 + Python 3.11 | Main web app, API, metrics endpoint |
| 2 | `postgres` | PostgreSQL 15 | Persistent storage for metrics |
| 3 | `redis` | Redis 7 | Response cache |
| 4 | `nginx` | Nginx | Reverse proxy and public entrypoint |
| 5 | `prometheus` | Prometheus | Metrics scraping and alerting |
| 6 | `grafana` | Grafana 10.4.7 | Dashboards and visualization |

> ℹ️ **Loki was removed** from the production compose stack to reduce memory/CPU usage on `t3.micro`.

---

## 📊 Architecture Diagram

```text
┌─────────────┐     ┌─────────────┐     ┌──────────────────┐
│   Browser   │────▶│    Nginx    │────▶│   Flask App      │
│   (User)    │     │   (port 80) │     │   (port 5000)    │
└─────────────┘     └─────────────┘     └──────┬───────────┘
                                               │
                         ┌─────────────────────┼─────────────────────┐
                         │                     │                     │
                   ┌─────▼─────┐       ┌──────▼──────┐      ┌──────▼──────┐
                   │ PostgreSQL │       │    Redis     │      │ Prometheus  │
                   │ (port 5432)│       │ (port 6379) │      │ (port 9090) │
                   └───────────┘       └─────────────┘      └──────┬──────┘
                                                                     │
                                                              ┌──────▼──────┐
                                                              │   Grafana   │
                                                              │ (port 3000) │
                                                              └─────────────┘
```

---

## 🔍 Service Responsibilities

### 1) Flask App (`app`)
- Exposes endpoints: `/`, `/health`, `/api/system-info`, `/metrics`
- Collects host metrics with `psutil`
- Stores historical values in PostgreSQL
- Uses Redis cache for faster API responses
- Outputs structured logs to container stdout

### 2) PostgreSQL (`postgres`)
- Persistent relational storage
- Runs inside internal network only (not publicly exposed)

### 3) Redis (`redis`)
- In-memory cache
- Reduces repeated metrics collection load

### 4) Nginx (`nginx`)
- Public entrypoint on port `80`
- Proxies requests to Flask app
- Adds security headers

### 5) Prometheus (`prometheus`)
- Scrapes `/metrics` from Flask app
- Current scrape interval in this project: `60s`
- Applies alert rules (`monitoring/alert_rules.yml`)

### 6) Grafana (`grafana`)
- Visualizes metrics from Prometheus datasource
- Dashboards are auto-provisioned from `monitoring/grafana/provisioning/`

---

## 🔄 Data Flow

### User request flow
1. User opens `http://localhost` (or public server URL)
2. Nginx receives request on port `80`
3. Nginx proxies request to Flask app (`app:5000`)
4. Flask app reads cache/data and returns response

### Monitoring flow
1. Flask exports Prometheus metrics at `/metrics`
2. Prometheus scrapes metrics every `60s`
3. Grafana queries Prometheus and renders dashboards
4. Alert rules are evaluated by Prometheus

### Logging flow
1. Flask writes structured logs to stdout
2. Docker captures logs (`docker compose logs`)
3. Logs can be shipped later to external log systems if needed

---

## 🌐 Network and Ports

| Service | Internal Port | External Port | Accessible From Host |
|---------|:-------------:|:-------------:|:--------------------:|
| Nginx | 80 | 80 | ✅ |
| Flask App | 5000 | 5000 | ✅ |
| PostgreSQL | 5432 | — | ❌ |
| Redis | 6379 | — | ❌ |
| Prometheus | 9090 | 9090 | ✅ |
| Grafana | 3000 | 3000 | ✅ |

---

## 🔒 Security Notes

- App container runs as non-root user
- PostgreSQL and Redis are internal-only
- Secrets are passed through environment variables / secrets files
- Nginx adds security headers
- Health checks are configured for critical services

---

## 📈 Scaling Notes

- Current setup is single-host (good for demo/lab)
- For higher load: scale app replicas via Kubernetes manifests/Helm
- Terraform + Ansible remain the base for infra + provisioning

---

## 📖 Related Documentation

- [DEPLOYMENT.md](./DEPLOYMENT.md)
- [MONITORING.md](./MONITORING.md)
- [CI_CD.md](./CI_CD.md)
