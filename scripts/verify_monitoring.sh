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
TARGET_VALIDATION_OUTPUT="$({
  TARGETS_JSON_ENV="$TARGETS_JSON" python3 - <<'PY'
import json
import os
import sys

raw = os.environ.get("TARGETS_JSON_ENV", "")
if not raw.strip():
    print("ERROR: empty response from Prometheus targets API")
    sys.exit(1)

try:
    payload = json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"ERROR: invalid JSON from Prometheus targets API: {exc}")
    sys.exit(1)

if payload.get("status") != "success":
    print(f"ERROR: Prometheus API status is '{payload.get('status')}', expected 'success'")
    if "error" in payload:
        print(f"DETAIL: {payload.get('error')}")
    sys.exit(1)

active_targets = payload.get("data", {}).get("activeTargets")
if not isinstance(active_targets, list):
    print("ERROR: missing or invalid data.activeTargets in Prometheus response")
    sys.exit(1)

required_jobs = ("flask-app", "prometheus")
job_targets = {job: [] for job in required_jobs}

for target in active_targets:
    labels = target.get("labels") or {}
    if not isinstance(labels, dict):
        continue
    job = labels.get("job")
    if job in job_targets:
        job_targets[job].append({
            "health": str(target.get("health", "unknown")).lower(),
            "lastError": target.get("lastError", "")
        })

errors = []
for job in required_jobs:
    targets = job_targets[job]
    if not targets:
        errors.append(f"- missing required target job '{job}'")
        continue

    if not any(t["health"] == "up" for t in targets):
        health_values = ", ".join(t["health"] for t in targets)
        last_errors = "; ".join(t["lastError"] or "<empty>" for t in targets)
        errors.append(
            f"- job '{job}' has no healthy targets (health={health_values}; lastError={last_errors})"
        )

if errors:
    print("ERROR: Prometheus target verification failed:")
    for item in errors:
        print(item)

    observed_jobs = sorted({(t.get("labels") or {}).get("job") for t in active_targets if isinstance((t.get("labels") or {}), dict) and (t.get("labels") or {}).get("job")})
    if observed_jobs:
        print("DETAIL: observed jobs: " + ", ".join(observed_jobs))
    else:
        print("DETAIL: no jobs were observed in activeTargets")
    sys.exit(1)

print("OK: required jobs are present and at least one target per job is healthy (health=up)")
PY
} 2>&1)" || {
  echo "❌ Prometheus target verification failed."
  echo "$TARGET_VALIDATION_OUTPUT"
  echo "Targets response excerpt:"
  echo "$TARGETS_JSON" | head -c 1000
  echo
  exit 1
}

echo "✅ $TARGET_VALIDATION_OUTPUT"

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
