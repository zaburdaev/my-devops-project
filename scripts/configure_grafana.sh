#!/usr/bin/env bash
set -euo pipefail

# This script is intended to run on the target server itself.
# It configures Grafana using local endpoints and does not depend on external host variables.
#
# Supported invocation styles:
#   1) ./configure_grafana.sh                            (uses env/defaults)
#   2) ./configure_grafana.sh <user> <password>
#   3) ./configure_grafana.sh <url> <user> <password>
GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_USER="${GRAFANA_USER:-${GF_SECURITY_ADMIN_USER:-admin}}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-${GF_SECURITY_ADMIN_PASSWORD:-admin}}"

if [[ $# -eq 3 ]]; then
  GRAFANA_URL="$1"
  GRAFANA_USER="$2"
  GRAFANA_PASSWORD="$3"
elif [[ $# -eq 2 ]]; then
  GRAFANA_USER="$1"
  GRAFANA_PASSWORD="$2"
elif [[ $# -eq 1 ]]; then
  if [[ "$1" == http://* || "$1" == https://* ]]; then
    GRAFANA_URL="$1"
  else
    GRAFANA_USER="$1"
  fi
fi

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

  PAYLOAD_FILE="$(mktemp)"
  RESPONSE_FILE="$(mktemp)"
  trap 'rm -f "${PAYLOAD_FILE}" "${RESPONSE_FILE}"' EXIT

  python3 - "${DASHBOARD_FILE}" > "${PAYLOAD_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    raw = json.load(f)

if isinstance(raw, dict) and "dashboard" in raw:
    payload = dict(raw)
    payload.setdefault("folderId", 0)
    payload.setdefault("overwrite", True)
else:
    payload = {"dashboard": raw, "folderId": 0, "overwrite": True}

payload.setdefault("message", "Automated dashboard import from configure_grafana.sh")

dashboard = payload.get("dashboard")
if not isinstance(dashboard, dict) or not dashboard.get("title"):
    raise SystemExit("Invalid dashboard JSON: missing dashboard.title")

json.dump(payload, sys.stdout)
PY

  HTTP_STATUS="$(curl -sS -o "${RESPONSE_FILE}" -w "%{http_code}" -X POST "${GRAFANA_URL}/api/dashboards/db" \
    -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    --data-binary "@${PAYLOAD_FILE}")"

  if [[ "${HTTP_STATUS}" =~ ^2[0-9]{2}$ ]]; then
    echo "✅ Dashboard imported successfully (HTTP ${HTTP_STATUS})."
  else
    echo "❌ Dashboard import failed (HTTP ${HTTP_STATUS})."
    echo "Grafana response:"
    cat "${RESPONSE_FILE}"
    echo
    echo "Payload preview:"
    python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1])), indent=2)[:2000])' "${PAYLOAD_FILE}" || true
    exit 1
  fi

  rm -f "${PAYLOAD_FILE}" "${RESPONSE_FILE}"
  trap - EXIT
else
  echo "Dashboard file not found: ${DASHBOARD_FILE}"
fi

echo "Grafana configuration completed."
