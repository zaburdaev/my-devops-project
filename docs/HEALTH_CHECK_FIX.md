# Health Check Fix

## Problem

Deployment health check was failing with messages like:

```text
⚠️ Health check failed
curl: (7) Failed to connect to localhost port 5000
```

## Root Causes

1. **Port 5000 was not published** — Flask app was reachable only inside Docker network.
2. **Health check started too early** — 15 seconds was not always enough for full startup.
3. **Production entrypoint is Nginx** — main external path is `http://localhost/health` on port 80.

## Solutions Applied

### 1) Published Flask Port

`docker-compose.yml` updated for `app` service:

```yaml
ports:
  - "5000:5000"
```

### 2) Increased Wait Time in CI/CD

`.github/workflows/ci-cd.yml` deploy step now waits 30 seconds:

```yaml
sleep 30
```

### 3) Improved Health Check Logic

Now deployment verifies both endpoints:

- ✅ Primary (production): `http://localhost/health` (via Nginx)
- ✅ Secondary (direct Flask): `http://localhost:5000/health`

### 4) Added Container Healthcheck

`app` service now includes Docker healthcheck to monitor internal `/health` endpoint.

## Verification Steps

After deployment on server:

```bash
cd /opt/health-dashboard
docker compose ps
curl -sSf http://localhost/health
curl -sSf http://localhost:5000/health
docker compose logs app --tail=50
```

Both health endpoints should return JSON with `"status": "healthy"`.

## Why This Matters

- **Production reliability:** main health check aligned to Nginx endpoint.
- **Developer convenience:** direct Flask access on port 5000 is available.
- **Better diagnostics:** CI/CD logs now clearly show which endpoint failed.
