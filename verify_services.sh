#!/bin/bash
set -u

ELASTIC_IP=$(cd terraform && terraform output -raw elastic_ip)

echo "Testing services on $ELASTIC_IP..."

FAILURES=0

if curl -fsS "http://$ELASTIC_IP:5000/health" >/dev/null; then
  echo "✅ Flask app healthy"
else
  echo "❌ Flask app failed"
  FAILURES=$((FAILURES+1))
fi

if curl -fsS "http://$ELASTIC_IP:9090/-/healthy" >/dev/null; then
  echo "✅ Prometheus healthy"
else
  echo "❌ Prometheus failed"
  FAILURES=$((FAILURES+1))
fi

if curl -fsS "http://$ELASTIC_IP:3000/api/health" >/dev/null; then
  echo "✅ Grafana healthy"
else
  echo "❌ Grafana failed"
  FAILURES=$((FAILURES+1))
fi

if [ "$FAILURES" -eq 0 ]; then
  echo "✅ All tests passed!"
  exit 0
else
  echo "❌ $FAILURES test(s) failed"
  exit 1
fi
