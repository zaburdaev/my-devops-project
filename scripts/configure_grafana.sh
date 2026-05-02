#!/usr/bin/env bash
set -euo pipefail

# This script is intended to run on the target server itself.
# It configures Grafana using local endpoints and does not depend on external host variables.
#
# Supported invocation styles:
#   1) ./configure_grafana.sh                            (uses args/env/.env + safe fallbacks)
#   2) ./configure_grafana.sh <user> <password>
#   3) ./configure_grafana.sh <url> <user> <password>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DASHBOARD_FILE="${SCRIPT_DIR}/../grafana/working-dashboard.json"
ENV_FILE="${GRAFANA_ENV_FILE:-${PROJECT_DIR}/.env}"

wait_attempts="${GRAFANA_WAIT_ATTEMPTS:-90}"
wait_sleep_seconds="${GRAFANA_WAIT_SLEEP_SECONDS:-5}"
datasource_retries="${GRAFANA_DATASOURCE_RETRIES:-5}"
import_retries="${GRAFANA_IMPORT_RETRIES:-8}"
import_retry_sleep_seconds="${GRAFANA_IMPORT_RETRY_SLEEP_SECONDS:-5}"

arg_url=""
arg_user=""
arg_password=""

if [[ $# -eq 3 ]]; then
  arg_url="$1"
  arg_user="$2"
  arg_password="$3"
elif [[ $# -eq 2 ]]; then
  arg_user="$1"
  arg_password="$2"
elif [[ $# -eq 1 ]]; then
  if [[ "$1" == http://* || "$1" == https://* ]]; then
    arg_url="$1"
  else
    arg_user="$1"
  fi
fi

mask_secret() {
  local value="${1:-}"
  if [[ -z "${value}" ]]; then
    printf '<empty>'
    return
  fi

  local length=${#value}
  if (( length <= 2 )); then
    printf '**'
  else
    printf '%s***%s (len=%d)' "${value:0:1}" "${value:length-1:1}" "${length}"
  fi
}

load_env_file() {
  if [[ -f "${ENV_FILE}" ]]; then
    echo "📄 Loading Grafana-related variables from ${ENV_FILE}"
    set -a
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
    set +a
  else
    echo "⚠️  Env file not found at ${ENV_FILE}; continuing with existing environment and defaults"
  fi
}

load_env_file

GRAFANA_URL="${arg_url:-${GRAFANA_URL:-http://localhost:3000}}"

# Build credential candidates (ordered by priority)
candidate_users=()
candidate_passwords=()
candidate_sources=()

add_candidate() {
  local user="${1:-}"
  local password="${2:-}"
  local source_label="${3:-unknown}"

  if [[ -z "${user}" || -z "${password}" ]]; then
    return
  fi

  local i
  for i in "${!candidate_users[@]}"; do
    if [[ "${candidate_users[$i]}" == "${user}" && "${candidate_passwords[$i]}" == "${password}" ]]; then
      return
    fi
  done

  candidate_users+=("${user}")
  candidate_passwords+=("${password}")
  candidate_sources+=("${source_label}")
}

add_candidate "${arg_user:-}" "${arg_password:-}" "cli-args"
add_candidate "${GRAFANA_USER:-}" "${GRAFANA_PASSWORD:-}" "GRAFANA_USER/GRAFANA_PASSWORD"
add_candidate "${GF_SECURITY_ADMIN_USER:-}" "${GF_SECURITY_ADMIN_PASSWORD:-}" "GF_SECURITY_ADMIN_USER/GF_SECURITY_ADMIN_PASSWORD"

# Safe fallback defaults (to match compose and legacy setup)
add_candidate "grafana_admin" "CHANGE_ME_STRONG_GRAFANA_PASSWORD" "docker-compose fallback"
add_candidate "admin" "admin" "legacy fallback"

if [[ ${#candidate_users[@]} -eq 0 ]]; then
  echo "❌ No Grafana credentials available from args/environment/.env"
  exit 1
fi

echo "🔎 Grafana URL: ${GRAFANA_URL}"
echo "🔎 Credential candidates (masked):"
for i in "${!candidate_users[@]}"; do
  echo "  - [${candidate_sources[$i]}] user='${candidate_users[$i]}', password='$(mask_secret "${candidate_passwords[$i]}")'"
done

echo "⏳ Waiting for Grafana to be ready at ${GRAFANA_URL} (up to $((wait_attempts * wait_sleep_seconds))s)..."
for ((i=1; i<=wait_attempts; i++)); do
  if curl -sf "${GRAFANA_URL}/api/health" >/dev/null; then
    echo "✅ Grafana health endpoint is reachable"
    break
  fi

  if (( i == wait_attempts )); then
    echo "❌ Grafana did not become ready in time"
    exit 1
  fi

  sleep "${wait_sleep_seconds}"
done

pick_working_credentials() {
  local status
  local response_file
  response_file="$(mktemp)"
  trap 'rm -f "${response_file}"' RETURN

  for i in "${!candidate_users[@]}"; do
    status="$(curl -sS -o "${response_file}" -w "%{http_code}" \
      -u "${candidate_users[$i]}:${candidate_passwords[$i]}" \
      "${GRAFANA_URL}/api/user" || true)"

    if [[ "${status}" == "200" ]]; then
      GRAFANA_USER="${candidate_users[$i]}"
      GRAFANA_PASSWORD="${candidate_passwords[$i]}"
      GRAFANA_CREDENTIAL_SOURCE="${candidate_sources[$i]}"
      echo "✅ Authenticated to Grafana with candidate [${GRAFANA_CREDENTIAL_SOURCE}] user='${GRAFANA_USER}'"
      return 0
    fi

    echo "⚠️  Candidate [${candidate_sources[$i]}] failed auth check (HTTP ${status})"
  done

  echo "❌ Unable to authenticate to Grafana with any available credentials"
  return 1
}

pick_working_credentials

echo "🔐 Using Grafana credentials: user='${GRAFANA_USER}', password='$(mask_secret "${GRAFANA_PASSWORD}")', source='${GRAFANA_CREDENTIAL_SOURCE}'"

configure_datasource() {
  local payload
  payload='{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }'

  local status
  local response_file
  response_file="$(mktemp)"
  trap 'rm -f "${response_file}"' RETURN

  for ((attempt=1; attempt<=datasource_retries; attempt++)); do
    status="$(curl -sS -o "${response_file}" -w "%{http_code}" -X POST "${GRAFANA_URL}/api/datasources" \
      -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      -d "${payload}" || true)"

    if [[ "${status}" =~ ^2[0-9]{2}$ || "${status}" == "409" ]]; then
      echo "✅ Prometheus datasource configured (HTTP ${status})"
      return 0
    fi

    echo "⚠️  Datasource setup attempt ${attempt}/${datasource_retries} failed (HTTP ${status})"
    cat "${response_file}" || true
    echo
    sleep "${import_retry_sleep_seconds}"
  done

  echo "❌ Failed to configure Prometheus datasource after ${datasource_retries} attempts"
  return 1
}

configure_datasource

if [[ -f "${DASHBOARD_FILE}" ]]; then
  echo "📊 Importing dashboard from ${DASHBOARD_FILE}..."

  payload_file="$(mktemp)"
  response_file="$(mktemp)"
  trap 'rm -f "${payload_file}" "${response_file}"' EXIT

  python3 - "${DASHBOARD_FILE}" > "${payload_file}" <<'PY'
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

  dashboard_import_ok=false
  for ((attempt=1; attempt<=import_retries; attempt++)); do
    http_status="$(curl -sS -o "${response_file}" -w "%{http_code}" -X POST "${GRAFANA_URL}/api/dashboards/db" \
      -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      --data-binary "@${payload_file}" || true)"

    if [[ "${http_status}" =~ ^2[0-9]{2}$ ]]; then
      echo "✅ Dashboard imported successfully (HTTP ${http_status})"
      dashboard_import_ok=true
      break
    fi

    echo "⚠️  Dashboard import attempt ${attempt}/${import_retries} failed (HTTP ${http_status})"
    echo "Grafana response:"
    cat "${response_file}" || true
    echo

    if (( attempt < import_retries )); then
      sleep "${import_retry_sleep_seconds}"
    fi
  done

  if [[ "${dashboard_import_ok}" != true ]]; then
    echo "❌ Dashboard import failed after ${import_retries} attempts"
    echo "Payload preview:"
    python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1])), indent=2)[:2000])' "${payload_file}" || true
    exit 1
  fi

  rm -f "${payload_file}" "${response_file}"
  trap - EXIT
else
  echo "⚠️  Dashboard file not found: ${DASHBOARD_FILE}"
fi

echo "🎉 Grafana configuration completed."