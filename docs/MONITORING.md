# 📊 Monitoring Guide

This guide explains the monitoring stack of the **Health Monitoring Dashboard** — how Prometheus, Grafana, and Loki work together to give you full observability into your application.

---

## 📋 Table of Contents

- [What Is Monitoring?](#-what-is-monitoring)
- [Monitoring Stack Overview](#-monitoring-stack-overview)
- [Prometheus](#-prometheus)
- [Grafana](#-grafana)
- [Loki](#-loki)
- [Pre-Built Dashboard](#-pre-built-dashboard)
- [Creating Custom Dashboards](#-creating-custom-dashboards)
- [Alert Configuration](#-alert-configuration)
- [Troubleshooting](#-troubleshooting)

---

## 💡 What Is Monitoring?

Monitoring means **watching your application** to make sure it's working correctly. Just like a doctor monitors a patient's vital signs (heart rate, blood pressure), we monitor our application's vital signs (CPU usage, memory, response time).

### Why Is Monitoring Important?

| Reason | Example |
|--------|---------|
| **Detect problems early** | CPU at 95% → app might crash soon |
| **Understand performance** | Average response time is 200ms → is that good enough? |
| **Investigate incidents** | "The app was slow at 2 PM" → check the dashboards for that time |
| **Plan capacity** | Memory usage growing → need to scale up soon |
| **Prove SLAs** | "Our uptime was 99.9% this month" |

### Three Pillars of Observability

1. **Metrics** (Prometheus) — Numbers over time: CPU 45%, Memory 67%, 500 requests/minute
2. **Logs** (Loki) — Text records of events: "User logged in", "Error connecting to database"
3. **Dashboards** (Grafana) — Visual display of metrics and logs

---

## 🗺️ Monitoring Stack Overview

```
┌─────────────────┐     scrapes /metrics      ┌──────────────┐
│   Flask App     │◀──────────────────────────│  Prometheus  │
│   (port 5000)   │       every 10 seconds     │  (port 9090) │
│                 │                            │              │
│  Exposes:       │                            │  Stores:     │
│  - cpu_usage    │                            │  - Metrics   │
│  - memory_usage │                            │  - Time      │
│  - disk_usage   │                            │    series    │
│  - request_total│                            └──────┬───────┘
│  - latency      │                                   │
└────────┬────────┘                                   │ queries
         │                                            │
         │ JSON logs                            ┌─────▼───────┐
         │                                      │   Grafana   │
         └──────────┐                           │  (port 3000)│
                    │                           │             │
                    ▼                           │  Displays:  │
              ┌──────────┐                      │  - Charts   │
              │   Loki   │──── queries ────────▶│  - Gauges   │
              │ (port 3100)│                     │  - Logs     │
              └──────────┘                      └─────────────┘
```

---

## 📈 Prometheus

### What Is Prometheus?

Prometheus is a **metrics collection and storage system**. It periodically "scrapes" (fetches) metrics from your application and stores them as time-series data (values that change over time).

### How It Works in Our Project

1. The Flask app exposes a `/metrics` endpoint with Prometheus-compatible data
2. Prometheus fetches this endpoint every **10 seconds**
3. The data is stored in Prometheus's time-series database
4. You can query this data using PromQL (Prometheus Query Language)

### Available Metrics

Our Flask app exposes these metrics:

| Metric | Type | Description |
|--------|------|-------------|
| `system_cpu_usage_percent` | Gauge | Current CPU usage percentage |
| `system_memory_usage_percent` | Gauge | Current memory usage percentage |
| `system_disk_usage_percent` | Gauge | Current disk usage percentage |
| `app_request_total` | Counter | Total number of HTTP requests |
| `app_request_latency_seconds` | Histogram | Request duration in seconds |

### Accessing Prometheus

1. Open [http://localhost:9090](http://localhost:9090) in your browser
2. You'll see the Prometheus expression browser

### Using Prometheus UI

#### Check Targets

Go to **Status** → **Targets** to see what Prometheus is scraping:

| Target | Endpoint | Expected State |
|--------|----------|:--------------:|
| prometheus | localhost:9090 | ✅ UP |
| health-dashboard | app:5000/metrics | ✅ UP |

If a target shows "DOWN", the service may not be running.

#### Query Metrics

In the expression box, try these queries:

```promql
# Current CPU usage
system_cpu_usage_percent

# Current memory usage
system_memory_usage_percent

# Request rate (requests per second over 5 minutes)
rate(app_request_total[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(app_request_latency_seconds_bucket[5m]))
```

Click **Execute** and then switch to the **Graph** tab to see a time-series chart.

### Prometheus Configuration

The configuration file is at `monitoring/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s       # Default scrape interval
  evaluation_interval: 15s   # How often to evaluate alert rules

scrape_configs:
  - job_name: "prometheus"   # Prometheus monitors itself
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "health-dashboard"  # Our Flask app
    scrape_interval: 10s          # Scrape more frequently
    metrics_path: "/metrics"
    static_configs:
      - targets: ["app:5000"]     # Service name in Docker network
```

---

## 📊 Grafana

### What Is Grafana?

Grafana is a **visualization and dashboarding platform**. It connects to data sources (like Prometheus and Loki) and displays the data in beautiful, interactive dashboards.

### How to Access Grafana

1. Open [http://localhost:3000](http://localhost:3000) in your browser
2. Login credentials:
   - **Username:** `admin`
   - **Password:** `admin`
3. When prompted to change password, you can skip or set a new one

### Data Sources (Pre-Configured)

Our project auto-configures two data sources for Grafana:

| Data Source | Type | URL | Used For |
|-------------|------|-----|----------|
| **Prometheus** | prometheus | http://prometheus:9090 | Metrics (CPU, memory, request rate) |
| **Loki** | loki | http://loki:3100 | Application logs |

> 💡 These are configured automatically via `monitoring/grafana/provisioning/datasources/datasources.yaml` — you don't need to set them up manually!

### Navigating Grafana

1. **Home** → The main page with recent dashboards
2. **Dashboards** → **Browse** → Find "Health Dashboard"
3. **Explore** → Write custom queries against Prometheus or Loki
4. **Alerting** → Configure and manage alerts

---

## 📊 Pre-Built Dashboard

The project includes a pre-built dashboard with 5 panels:

### Panel 1: 🖥️ CPU Usage (Gauge)

- **Query:** `system_cpu_usage_percent`
- **Thresholds:**
  - 🟢 Green: 0-60% (normal)
  - 🟡 Yellow: 60-80% (warning)
  - 🔴 Red: 80-100% (critical)

### Panel 2: 🧠 Memory Usage (Gauge)

- **Query:** `system_memory_usage_percent`
- **Thresholds:**
  - 🟢 Green: 0-60%
  - 🟡 Yellow: 60-85%
  - 🔴 Red: 85-100%

### Panel 3: 💾 Disk Usage (Gauge)

- **Query:** `system_disk_usage_percent`
- **Thresholds:**
  - 🟢 Green: 0-70%
  - 🟡 Yellow: 70-90%
  - 🔴 Red: 90-100%

### Panel 4: 📈 Request Rate (Time Series)

- **Query:** `rate(app_request_total[5m])`
- Shows how many requests per second the app handles over time

### Panel 5: ⏱️ Request Latency P95 (Time Series)

- **Query:** `histogram_quantile(0.95, rate(app_request_latency_seconds_bucket[5m]))`
- Shows the 95th percentile response time (95% of requests are faster than this)

> 💡 The dashboard auto-refreshes every **10 seconds**. You can change this in the top-right corner of Grafana.

---

## 📝 Loki

### What Is Loki?

Loki is a **log aggregation system** designed to work with Grafana. Think of it as "Prometheus, but for logs." It stores and indexes logs so you can search through them.

### How It Works

1. The Flask app outputs structured JSON logs to stdout
2. Docker captures these logs
3. Loki collects and stores them
4. Grafana queries Loki to display logs

### Viewing Logs in Grafana

1. Open Grafana → **Explore** (compass icon in the sidebar)
2. Select **Loki** as the data source (top dropdown)
3. In the query box, try:

```logql
{job="health-dashboard"}
```

4. Click **Run Query** to see the logs

### Useful Loki Queries

```logql
# All logs from the app
{job="health-dashboard"}

# Only error logs
{job="health-dashboard"} |= "ERROR"

# Search for specific text
{job="health-dashboard"} |= "health check"

# Parse JSON and filter
{job="health-dashboard"} | json | level="ERROR"
```

### Loki Configuration

The configuration file is at `monitoring/loki-config.yaml`:

```yaml
server:
  http_listen_port: 3100      # Loki listens on port 3100

auth_enabled: false            # No authentication (for simplicity)

limits_config:
  reject_old_samples: true     # Don't accept very old logs
  reject_old_samples_max_age: 168h  # Max age: 7 days
```

---

## 🎨 Creating Custom Dashboards

### Step 1: Open Grafana

Go to [http://localhost:3000](http://localhost:3000) and log in.

### Step 2: Create a New Dashboard

1. Click **"+"** (plus icon) in the sidebar → **"New Dashboard"**
2. Click **"Add visualization"**

### Step 3: Add a Panel

1. Select **Prometheus** as the data source
2. Enter a PromQL query, for example:
   ```
   system_cpu_usage_percent
   ```
3. Choose a visualization type (Graph, Gauge, Stat, Table, etc.)
4. Configure the panel title and description
5. Click **Apply**

### Step 4: Save the Dashboard

1. Click the **save icon** (💾) at the top
2. Give your dashboard a name
3. Click **Save**

### Example: Custom Request Monitoring Dashboard

| Panel | Query | Type |
|-------|-------|------|
| Total Requests | `app_request_total` | Stat |
| Requests/Second | `rate(app_request_total[1m])` | Graph |
| Avg Latency | `rate(app_request_latency_seconds_sum[5m]) / rate(app_request_latency_seconds_count[5m])` | Gauge |
| Error Rate | `rate(app_request_total{status=~"5.."}[5m])` | Graph |

---

## 🔔 Alert Configuration

The project includes alert rules defined in `monitoring/alert_rules.yml`:

### Pre-Configured Alerts

| Alert | Condition | Severity | Duration |
|-------|-----------|:--------:|:--------:|
| **HighCpuUsage** | CPU > 80% | ⚠️ Warning | 5 minutes |
| **HighMemoryUsage** | Memory > 85% | ⚠️ Warning | 5 minutes |
| **AppDown** | App is unreachable | 🔴 Critical | 1 minute |

### How Alerts Work

1. Prometheus evaluates alert rules every 15 seconds
2. If a condition is true for the specified duration, the alert "fires"
3. Fired alerts can be seen in Prometheus UI: **Alerts** tab
4. In a production setup, you would add an **Alertmanager** to send notifications (email, Slack, PagerDuty)

### Alert Rules File

```yaml
# monitoring/alert_rules.yml
groups:
  - name: health-dashboard-alerts
    rules:
      - alert: HighCpuUsage
        expr: system_cpu_usage_percent > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 5 minutes"

      - alert: HighMemoryUsage
        expr: system_memory_usage_percent > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"

      - alert: AppDown
        expr: up{job="health-dashboard"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Health Dashboard is down!"
```

---

## 🔧 Troubleshooting

### ❌ Grafana Shows "No Data"

**Possible causes:**
1. Prometheus hasn't collected enough data yet
2. The Flask app is not running
3. Data source is misconfigured

**Solutions:**
```bash
# 1. Check if all services are running
docker-compose ps

# 2. Check Prometheus targets
# Open http://localhost:9090/targets — all should be UP

# 3. Check if metrics are being produced
curl http://localhost:5000/metrics

# 4. Wait 30-60 seconds for data to appear
```

### ❌ Prometheus Target is "DOWN"

**Problem:** Prometheus can't reach the Flask app.

**Solution:**
```bash
# Check if the app is running
docker-compose logs app

# Restart the app
docker-compose restart app
```

### ❌ Loki Shows No Logs

**Problem:** Loki is not receiving logs from the application.

**Solution:**
1. Check if Loki is running: `docker-compose logs loki`
2. Check the Loki data source in Grafana: Settings → Data Sources → Loki → "Test"
3. Make sure the Flask app is producing logs: `docker-compose logs app`

---

## 📖 Related Documentation

- 🏗️ [Architecture](./ARCHITECTURE.md) — System design overview
- 🚀 [Getting Started](./GETTING_STARTED.md) — Set up the project locally
- 🔄 [CI/CD](./CI_CD.md) — Automated pipeline
- 🧪 [Testing](./TESTING.md) — Testing guide

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>
