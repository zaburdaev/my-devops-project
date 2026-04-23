# 🏗️ Architecture Documentation

This document explains the system architecture of the **Health Monitoring Dashboard** — how all the components work together, what each service does, and how data flows through the system.

---

## 📋 Table of Contents

- [System Overview](#-system-overview)
- [Architecture Diagram](#-architecture-diagram)
- [Services Description](#-services-description)
- [Data Flow](#-data-flow)
- [Network Architecture](#-network-architecture)
- [Security Considerations](#-security-considerations)
- [Scalability Considerations](#-scalability-considerations)

---

## 🌐 System Overview

The Health Monitoring Dashboard is a **microservices-based** application composed of 7 Docker containers that work together:

| # | Service | Technology | Role |
|---|---------|-----------|------|
| 1 | **app** | Flask (Python) | The main application — collects and serves system metrics |
| 2 | **postgres** | PostgreSQL 15 | Stores metrics data persistently |
| 3 | **redis** | Redis 7 | Caches metrics for fast responses |
| 4 | **nginx** | Nginx | Reverse proxy — the front door for users |
| 5 | **prometheus** | Prometheus | Scrapes and stores time-series metrics |
| 6 | **grafana** | Grafana | Visualizes metrics on beautiful dashboards |
| 7 | **loki** | Loki | Aggregates and stores application logs |

---

## 📊 Architecture Diagram

```
                            ┌──────────────────────────────────────────────┐
                            │              Docker Network                  │
                            │            (app-network)                     │
                            │                                              │
┌──────────┐  HTTP :80      │  ┌─────────┐   proxy    ┌────────────────┐  │
│          │───────────────────▶│  Nginx  │──────────▶│   Flask App     │  │
│  Browser │                │  │ :80     │           │   :5000         │  │
│  (User)  │                │  └─────────┘           │                 │  │
│          │                │                        │  ┌───────────┐  │  │
└──────────┘                │                        │  │  psutil   │  │  │
                            │                        │  │ (metrics) │  │  │
                            │                        │  └───────────┘  │  │
     ┌──────────┐           │                        └──┬──────┬───┬──┘  │
     │ Grafana  │           │                           │      │   │     │
     │  :3000   │◀──────────│───────────┐               │      │   │     │
     └──┬───────┘           │           │               │      │   │     │
        │                   │     ┌─────┴──────┐   ┌────▼──┐ ┌─▼───▼──┐  │
        │                   │     │ Prometheus  │   │ Redis │ │Postgres│  │
        │                   │     │   :9090     │   │ :6379 │ │ :5432  │  │
        │                   │     │             │   └───────┘ └────────┘  │
        │                   │     └─────────────┘                         │
        │                   │           ▲                                  │
        │                   │           │ scrapes /metrics                 │
        │                   │           │ every 10 seconds                 │
        │                   │                                              │
        │  ┌──────────┐     │                                              │
        └─▶│   Loki   │     │                                              │
           │  :3100   │     │                                              │
           └──────────┘     │                                              │
                            └──────────────────────────────────────────────┘
```

---

## 🔍 Services Description

### 1. 🐍 Flask App (app)

**What it is:** The core application — a Python web server built with Flask.

**What it does:**
- Collects system metrics (CPU, memory, disk) using the `psutil` library
- Serves a web dashboard (HTML page) at `/`
- Provides a REST API:
  - `GET /health` — Returns application health status
  - `GET /api/system-info` — Returns detailed system metrics (JSON)
  - `GET /metrics` — Exposes Prometheus-compatible metrics
- Stores metrics in PostgreSQL for historical data
- Uses Redis to cache responses (10-second TTL) for better performance
- Outputs structured JSON logs (readable by Loki)

**Technical details:**
- **Runtime:** Python 3.11 + Gunicorn (2 workers)
- **Port:** 5000 (internal)
- **Docker image:** `oskalibriya/health-dashboard`
- **Health check:** `GET /health` every 30 seconds
- **Runs as:** Non-root user (`appuser`) for security

### 2. 🐘 PostgreSQL (postgres)

**What it is:** A relational database — one of the most popular open-source databases in the world.

**What it does:**
- Stores system metrics data persistently (data survives container restarts)
- The Flask app creates a `metrics` table on startup and writes metrics to it
- Data is stored in a Docker volume (`postgres_data`) so it's not lost when containers stop

**Technical details:**
- **Image:** `postgres:15-alpine` (lightweight Alpine Linux variant)
- **Port:** 5432 (internal only — not exposed to the host for security)
- **Health check:** `pg_isready` command
- **Database name:** `health_dashboard` (configurable via `.env`)

> 💡 **Why PostgreSQL?** It's reliable, feature-rich, and widely used in production. It demonstrates persistent storage in a DevOps context.

### 3. ⚡ Redis (redis)

**What it is:** An in-memory data store used as a cache.

**What it does:**
- Caches the response from `/api/system-info` for 10 seconds
- When a user requests system info, the app first checks Redis:
  - **Cache hit:** Returns data instantly from memory (fast! ⚡)
  - **Cache miss:** Collects fresh metrics, stores in Redis, then returns

**Technical details:**
- **Image:** `redis:7-alpine`
- **Port:** 6379 (internal only)
- **Health check:** `redis-cli ping`
- **TTL (Time-To-Live):** 10 seconds

> 💡 **Why Redis?** It's extremely fast because data is stored in RAM. It reduces load on the application by serving cached responses.

### 4. 🌐 Nginx (nginx)

**What it is:** A web server and reverse proxy.

**What it does:**
- Acts as the "front door" — all user traffic enters through Nginx on port 80
- Forwards requests to the Flask app running on port 5000
- Adds security headers to responses
- Provides its own health check endpoint at `/nginx-health`
- Exposes the `/metrics` path directly for Prometheus scraping

**Technical details:**
- **Image:** `nginx:alpine`
- **Port:** 80 (exposed to the host)
- **Configuration:** `nginx/nginx.conf`

> 💡 **Why Nginx?** In production, you never expose a Python app directly to the internet. Nginx handles things like load balancing, SSL termination, and security headers.

### 5. 📈 Prometheus (prometheus)

**What it is:** A monitoring and alerting toolkit designed for reliability.

**What it does:**
- **Scrapes** (fetches) metrics from the Flask app's `/metrics` endpoint every 10 seconds
- Stores metrics as time-series data (values with timestamps)
- Provides a query language (PromQL) to analyze metrics
- Can trigger alerts based on rules (e.g., CPU > 80%)
- Also monitors itself

**Technical details:**
- **Image:** `prom/prometheus`
- **Port:** 9090 (exposed to the host)
- **Configuration:** `monitoring/prometheus.yml`
- **Alert rules:** `monitoring/alert_rules.yml`
- **Scrape targets:**
  - `health-dashboard` job → Flask app on port 5000
  - `prometheus` job → itself on port 9090

> 💡 **Why Prometheus?** It's the industry standard for monitoring in cloud-native environments. It integrates seamlessly with Grafana and Kubernetes.

### 6. 📊 Grafana (grafana)

**What it is:** An analytics and visualization platform.

**What it does:**
- Connects to Prometheus (for metrics) and Loki (for logs) as data sources
- Displays beautiful, auto-refreshing dashboards
- The project comes with a **pre-built dashboard** showing:
  - 🖥️ CPU Usage gauge
  - 🧠 Memory Usage gauge
  - 💾 Disk Usage gauge
  - 📈 Request Rate over time
  - ⏱️ Request Latency (p95) over time
- Refreshes every 10 seconds automatically

**Technical details:**
- **Image:** `grafana/grafana`
- **Port:** 3000 (exposed to the host)
- **Default login:** admin / admin
- **Provisioning:** Auto-configured datasources and dashboards via `grafana/provisioning/`
- **Data persistence:** `grafana_data` Docker volume

> 💡 **Why Grafana?** It's the go-to tool for visualizing monitoring data. It supports dozens of data sources and is highly customizable.

### 7. 📝 Loki (loki)

**What it is:** A log aggregation system (like Prometheus, but for logs).

**What it does:**
- Receives and stores structured JSON logs from the Flask application
- Makes logs searchable and queryable from Grafana
- Stores logs efficiently using an index + chunks approach

**Technical details:**
- **Image:** `grafana/loki`
- **Port:** 3100 (exposed to the host)
- **Configuration:** `monitoring/loki-config.yaml`
- **Storage:** Filesystem-based (BoltDB + filesystem)
- **Log retention:** 168 hours (7 days)

> 💡 **Why Loki?** It's designed by the Grafana team and integrates perfectly with Grafana. It's lightweight compared to alternatives like Elasticsearch.

---

## 🔄 Data Flow

### User Request Flow

```
1. User opens http://localhost in browser
2. Request hits Nginx (port 80)
3. Nginx forwards request to Flask App (port 5000)
4. Flask App checks Redis cache:
   a. Cache HIT  → Returns cached data immediately
   b. Cache MISS → Collects system metrics with psutil
                  → Saves to PostgreSQL (for history)
                  → Stores in Redis (for caching)
                  → Returns data to user
5. Response travels back: Flask → Nginx → Browser
```

### Monitoring Flow

```
1. Prometheus scrapes Flask App's /metrics endpoint every 10 seconds
2. Prometheus stores metrics as time-series data
3. Grafana queries Prometheus for dashboard data
4. Grafana displays metrics on pre-built dashboards
5. Alert rules evaluate metrics (CPU > 80%, Memory > 85%, App down)
```

### Logging Flow

```
1. Flask App generates structured JSON logs
2. Logs are written to stdout (standard output)
3. Docker captures stdout logs
4. Loki can collect and aggregate these logs
5. Grafana queries Loki to display logs alongside metrics
```

---

## 🌐 Network Architecture

All services communicate over a shared Docker network called `app-network`.

### Port Mapping

| Service | Internal Port | External Port | Accessible From Host? |
|---------|:------------:|:-------------:|:---------------------:|
| Nginx | 80 | 80 | ✅ Yes |
| Flask App | 5000 | 5000 | ✅ Yes |
| PostgreSQL | 5432 | — | ❌ No (internal only) |
| Redis | 6379 | — | ❌ No (internal only) |
| Prometheus | 9090 | 9090 | ✅ Yes |
| Grafana | 3000 | 3000 | ✅ Yes |
| Loki | 3100 | 3100 | ✅ Yes |

> 💡 **Why are PostgreSQL and Redis not exposed?** For security. Only the services that need public access are exposed. The database and cache are only accessible by other containers on the same Docker network.

### Service Discovery

Docker Compose automatically sets up DNS within the `app-network`. Services can find each other by their service name:
- The Flask app connects to `postgres:5432` (not `localhost:5432`)
- The Flask app connects to `redis:6379`
- Prometheus scrapes `app:5000/metrics`
- Grafana connects to `prometheus:9090` and `loki:3100`

---

## 🔒 Security Considerations

This project implements several security best practices:

| Practice | Where | Description |
|----------|-------|-------------|
| **Non-root container** | `Dockerfile` | Flask app runs as `appuser`, not root |
| **Internal-only databases** | `docker-compose.yml` | PostgreSQL & Redis are not exposed to the host |
| **Environment variables** | `.env` | Secrets are not hardcoded in code |
| **`.gitignore`** | `.gitignore` | `.env` file is never committed to Git |
| **Security headers** | `nginx.conf` | Nginx adds security headers to responses |
| **Health checks** | `docker-compose.yml` | All critical services have health checks |
| **Multi-stage build** | `Dockerfile` | Build tools are not included in the production image |
| **Base64 secrets** | `k8s/secret.yaml` | Kubernetes secrets are encoded |

### ⚠️ Production Recommendations

For a production environment, you should also:
- Use HTTPS (SSL/TLS certificates) via Nginx or a load balancer
- Use strong, unique passwords for PostgreSQL and Grafana
- Restrict network access with firewall rules
- Use a secrets manager (AWS Secrets Manager, HashiCorp Vault)
- Enable Grafana authentication with proper user management
- Set up regular database backups
- Use image vulnerability scanning (e.g., Trivy)

---

## 📈 Scalability Considerations

### Current Setup (Single Host)

The current Docker Compose setup runs all services on a single host. This is perfect for development and small-scale deployments.

### Scaling Options

| Approach | How | When to Use |
|----------|-----|-------------|
| **Vertical scaling** | Use a bigger server (more CPU, RAM) | Quick fix for growing traffic |
| **Horizontal scaling (Docker)** | `docker-compose up --scale app=3` | Multiple Flask instances behind Nginx |
| **Kubernetes** | Use the included K8s manifests | Production-grade orchestration |
| **Helm chart** | `helm install health-dashboard ./k8s/helm/health-dashboard` | Customizable K8s deployment |

### Kubernetes Architecture

The included Kubernetes configuration provides:
- **2 replicas** of the Flask app (configurable)
- **LoadBalancer** service for external access
- **Readiness & liveness probes** for automatic health management
- **Resource limits** to prevent one pod from consuming all resources
- **ConfigMaps** for configuration and **Secrets** for sensitive data

```
                    ┌─────────────────────────┐
                    │   Kubernetes Cluster     │
                    │                          │
Internet ──▶ LoadBalancer ──┬──▶ Pod 1 (Flask) │
                    │       └──▶ Pod 2 (Flask) │
                    │                          │
                    │    ConfigMap  Secret      │
                    └─────────────────────────┘
```

---

## 📖 Related Documentation

- 🚀 [Getting Started](./GETTING_STARTED.md) — Set up the project locally
- 🚀 [Deployment](./DEPLOYMENT.md) — Deploy to AWS, K8s, or with Ansible
- 📊 [Monitoring](./MONITORING.md) — Deep dive into the monitoring stack
- 🔄 [CI/CD](./CI_CD.md) — Understand the automated pipeline

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>
