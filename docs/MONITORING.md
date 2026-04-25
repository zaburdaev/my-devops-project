# 📊 Monitoring Guide

This guide describes the **current monitoring stack** of the project.

---

## ✅ Current Stack

- **Prometheus** — metrics collection and alert rules
- **Grafana 10.4.7** — visualization and dashboards
- **Flask `/metrics` endpoint** — metric source

> ℹ️ **Loki was removed** from the runtime stack during optimization for low-resource EC2 (`t3.micro`).

---

## 🧩 Components

### Prometheus
- URL: `http://localhost:9090`
- Scrape interval: `60s`
- Config: `monitoring/prometheus.yml`
- Alerts: `monitoring/alert_rules.yml`

### Grafana
- URL: `http://localhost:3000`
- Default login: from `.env` (`GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD`)
- Provisioning:
  - Datasource: `monitoring/grafana/provisioning/datasources/datasources.yaml`
  - Dashboards provider: `monitoring/grafana/provisioning/dashboards/`
  - Dashboards JSON: `monitoring/grafana/dashboards/`

### Application metrics
- Endpoint: `http://localhost:5000/metrics`
- Exported by Flask app for Prometheus scraping

---

## 🚀 Run and Verify

```bash
docker compose up -d --build
```

Check services:

```bash
docker compose ps
curl -f http://localhost:5000/health
curl -f http://localhost:9090/-/ready
curl -f http://localhost:3000/api/health
```

---

## 📈 Typical Checks in Prometheus

Open: `http://localhost:9090/targets`

Expected:
- `prometheus` target: UP
- `flask-app` (or configured app target): UP

Useful query examples:

```promql
up
system_cpu_usage_percent
system_memory_usage_percent
rate(app_request_total[5m])
```

---

## 📉 Typical Checks in Grafana

1. Open `http://localhost:3000`
2. Verify datasource **Prometheus** is healthy
3. Open dashboard and ensure panels show live values

---

## 📝 Logging After Loki Removal

Current logging path:
- Flask writes structured logs to stdout
- Docker stores them in container logs

Examples:

```bash
docker compose logs app --tail=100
docker compose logs -f app
```

If centralized logs are required in future, add a lightweight shipper (e.g., Promtail/Vector) or managed cloud logging.

---

## ⚠️ Troubleshooting

### Prometheus target is DOWN
- Ensure `app` container is healthy
- Confirm `/metrics` endpoint responds
- Check `monitoring/prometheus.yml` target name and port

### Grafana has no data
- Validate Prometheus datasource URL (`http://prometheus:9090` inside docker network)
- Ensure Prometheus has recent samples

### Grafana login fails
- Verify `.env` credentials
- Restart Grafana after `.env` change

---

## 📚 Related Docs

- [ARCHITECTURE.md](./ARCHITECTURE.md)
- [DEPLOYMENT.md](./DEPLOYMENT.md)
- [TROUBLESHOOTING_RU.md](./TROUBLESHOOTING_RU.md)
