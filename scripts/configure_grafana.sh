#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <server_ip_or_host> [grafana_user] [grafana_password]"
  exit 1
fi

SERVER_HOST="$1"
GRAFANA_USER="${2:-admin}"
GRAFANA_PASSWORD="${3:-admin}"
GRAFANA_URL="http://${SERVER_HOST}:3000"
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
  python3 - <<'PY'
import json, os, urllib.request

server = os.environ['SERVER_HOST']
user = os.environ['GRAFANA_USER']
password = os.environ['GRAFANA_PASSWORD']
file_path = os.environ['DASHBOARD_FILE']

with open(file_path, 'r', encoding='utf-8') as f:
    dashboard = json.load(f)

payload = json.dumps({
    "dashboard": dashboard,
    "folderId": 0,
    "overwrite": True
}).encode('utf-8')

req = urllib.request.Request(
    f"http://{server}:3000/api/dashboards/db",
    data=payload,
    headers={"Content-Type": "application/json"},
    method="POST"
)
base64_auth = (f"{user}:{password}").encode('utf-8')
import base64
req.add_header('Authorization', 'Basic ' + base64.b64encode(base64_auth).decode('ascii'))
with urllib.request.urlopen(req, timeout=30) as resp:
    print(resp.read().decode('utf-8'))
PY
fi

echo "Grafana configuration completed."
