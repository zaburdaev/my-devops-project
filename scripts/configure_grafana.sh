#!/usr/bin/env bash
set -euo pipefail

# This script is intended to run on the target server itself.
# It configures Grafana using local endpoints and does not require SERVER_HOST.
GRAFANA_USER="${1:-${GRAFANA_USER:-admin}}"
GRAFANA_PASSWORD="${2:-${GRAFANA_PASSWORD:-admin}}"
GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASHBOARD_FILE="${SCRIPT_DIR}/../grafana/working-dashboard.json"

echo "Waiting for Grafana to be ready at ${GRAFANA_URL}..."
for i in {1..30}; do
  if curl -sf "${GRAFANA_URL}/api/health" >/dev/null; then
    break
  fi
  sleep 5
done

curl -sf "${GRAFANA_URL}/api/health" >/dev/null

echo "Configuring Prometheus data source..."
curl -sS -X POST "${GRAFANA_URL}/api/datasources" \
  -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }' >/dev/null || true

if [[ -f "${DASHBOARD_FILE}" ]]; then
  echo "Importing dashboard from ${DASHBOARD_FILE}..."
  GRAFANA_URL="${GRAFANA_URL}" \
  GRAFANA_USER="${GRAFANA_USER}" \
  GRAFANA_PASSWORD="${GRAFANA_PASSWORD}" \
  DASHBOARD_FILE="${DASHBOARD_FILE}" \
  python3 - <<'PY'
import base64
import json
import os
import urllib.request

base_url = os.environ["GRAFANA_URL"].rstrip("/")
user = os.environ["GRAFANA_USER"]
password = os.environ["GRAFANA_PASSWORD"]
file_path = os.environ["DASHBOARD_FILE"]

with open(file_path, "r", encoding="utf-8") as f:
    dashboard = json.load(f)

payload = json.dumps(
    {
        "dashboard": dashboard,
        "folderId": 0,
        "overwrite": True,
    }
).encode("utf-8")

req = urllib.request.Request(
    f"{base_url}/api/dashboards/db",
    data=payload,
    headers={"Content-Type": "application/json"},
    method="POST",
)
req.add_header(
    "Authorization",
    "Basic " + base64.b64encode(f"{user}:{password}".encode("utf-8")).decode("ascii"),
)

with urllib.request.urlopen(req, timeout=30) as resp:
    print(resp.read().decode("utf-8"))
PY
else
  echo "Dashboard file not found: ${DASHBOARD_FILE}"
fi

echo "Grafana configuration completed."
