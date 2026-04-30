#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ -f "${PROJECT_ROOT}/.env" ]]; then
  set -a
  source "${PROJECT_ROOT}/.env"
  set +a
fi

PROMETHEUS_URL="${PROMETHEUS_URL:-http://localhost:9090}"
GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_USER="${GF_SECURITY_ADMIN_USER:-admin}"
GRAFANA_PASSWORD="${GF_SECURITY_ADMIN_PASSWORD:-admin}"
DASHBOARD_UID="${DASHBOARD_UID:-health-dashboard-working}"

wait_for_url() {
  local url="$1"
  local name="$2"
  local attempts="${3:-24}"
  local sleep_seconds="${4:-5}"

  for ((i=1; i<=attempts; i++)); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo "✅ ${name} is reachable: ${url}"
      return 0
    fi
    echo "⏳ Waiting for ${name} (${i}/${attempts})..."
    sleep "$sleep_seconds"
  done

  echo "❌ ${name} is not reachable after $((attempts * sleep_seconds)) seconds: ${url}"
  return 1
}

echo "🔍 Verifying monitoring stack..."

# 1) Prometheus is up
wait_for_url "${PROMETHEUS_URL}/-/healthy" "Prometheus health endpoint"

# 2) Prometheus is scraping targets
TARGETS_JSON="$(curl -fsS "${PROMETHEUS_URL}/api/v1/targets")"
TARGET_CHECK="$(python3 - <<'PY' "$TARGETS_JSON"
import json
import sys

data = json.loads(sys.argv[1])
active = data.get("data", {}).get("activeTargets", [])
required = {"prometheus", "flask-app"}
health_by_job = {job: False for job in required}
for target in active:
    job = target.get("labels", {}).get("job")
    if job in health_by_job and target.get("health") == "up":
        health_by_job[job] = True

missing = [job for job, ok in health_by_job.items() if not ok]
if missing:
    print("MISSING:" + ",".join(missing))
    sys.exit(1)
print("OK")
PY
)" || {
  echo "❌ Prometheus target verification failed."
  echo "Targets response excerpt:"
  echo "$TARGETS_JSON" | head -c 500
  echo
  exit 1
}

echo "✅ Prometheus is scraping required targets (prometheus, flask-app)."

# 3) Grafana is up
wait_for_url "${GRAFANA_URL}/api/health" "Grafana health endpoint"

# 4) Working dashboard exists in Grafana
DASHBOARD_RESPONSE="$(curl -fsS -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" "${GRAFANA_URL}/api/dashboards/uid/${DASHBOARD_UID}")" || {
  echo "❌ Failed to fetch Grafana dashboard by UID: ${DASHBOARD_UID}"
  exit 1
}

python3 - <<'PY' "$DASHBOARD_RESPONSE"
import json
import sys

payload = json.loads(sys.argv[1])
dashboard = payload.get("dashboard") or {}
title = dashboard.get("title")
uid = dashboard.get("uid")
if not dashboard or not uid:
    print("❌ Dashboard payload is empty or invalid")
    sys.exit(1)
print(f"✅ Grafana dashboard found: {title} (uid={uid})")
PY

echo "🎉 Monitoring verification completed successfully."
