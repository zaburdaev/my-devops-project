"""
Flask Health Dashboard Application
Author: Vitalii Zaburdaiev
Course: DevOpsUA6

A system health monitoring dashboard that exposes CPU, memory, disk,
and uptime metrics via REST API endpoints. Integrates with PostgreSQL
for persistence, Redis for caching, and Prometheus for metrics collection.
"""

import os
import time
import json
import logging
import datetime
import platform
import secrets
import psutil
from flask import Flask, jsonify, request, render_template_string
from prometheus_client import (
    Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
)
from flask import Response

# ---------------------------------------------------------------------------
# Logging configuration (JSON format for Loki)
# ---------------------------------------------------------------------------

class JSONFormatter(logging.Formatter):
    """Custom JSON formatter for structured logging (Loki-compatible)."""
    def format(self, record):
        log_record = {
            "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
            "module": record.module,
        }
        if record.exc_info:
            log_record["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_record)


handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logging.basicConfig(level=logging.INFO, handlers=[handler])
logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Prometheus metrics
# ---------------------------------------------------------------------------

REQUEST_COUNT = Counter(
    "app_request_total",
    "Total number of requests",
    ["method", "endpoint", "http_status"],
)
REQUEST_LATENCY = Histogram(
    "app_request_latency_seconds",
    "Request latency in seconds",
    ["endpoint"],
)
SYSTEM_CPU = Gauge("system_cpu_usage_percent", "Current CPU usage in percent")
SYSTEM_MEMORY = Gauge("system_memory_usage_percent", "Current memory usage in percent")
SYSTEM_DISK = Gauge("system_disk_usage_percent", "Current disk usage in percent")

# ---------------------------------------------------------------------------
# Application start time (for uptime calculation)
# ---------------------------------------------------------------------------

APP_START_TIME = time.time()

# ---------------------------------------------------------------------------
# Optional: database & cache helpers
# ---------------------------------------------------------------------------

def get_db_connection():
    """Return a psycopg2 connection using env vars. Returns None on failure."""
    try:
        import psycopg2
        conn = psycopg2.connect(
            host=os.getenv("POSTGRES_HOST", "postgres"),
            port=int(os.getenv("POSTGRES_PORT", 5432)),
            dbname=os.getenv("POSTGRES_DB", "healthdb"),
            user=os.getenv("POSTGRES_USER", "health_admin"),
            password=os.getenv("POSTGRES_PASSWORD", ""),
        )
        return conn
    except Exception as exc:
        logger.warning("Could not connect to PostgreSQL: %s", exc)
        return None


def get_redis_client():
    """Return a Redis client using env vars. Returns None on failure."""
    try:
        import redis
        client = redis.Redis(
            host=os.getenv("REDIS_HOST", "redis"),
            port=int(os.getenv("REDIS_PORT", 6379)),
            db=0,
            decode_responses=True,
        )
        client.ping()
        return client
    except Exception as exc:
        logger.warning("Could not connect to Redis: %s", exc)
        return None


def init_db():
    """Create the metrics table if it does not exist."""
    conn = get_db_connection()
    if conn:
        try:
            cur = conn.cursor()
            cur.execute("""
                CREATE TABLE IF NOT EXISTS metrics (
                    id SERIAL PRIMARY KEY,
                    timestamp TIMESTAMPTZ DEFAULT NOW(),
                    cpu_percent FLOAT,
                    memory_percent FLOAT,
                    disk_percent FLOAT
                );
            """)
            conn.commit()
            cur.close()
            conn.close()
            logger.info("Database initialized successfully")
        except Exception as exc:
            logger.error("DB init error: %s", exc)


def save_metrics(cpu, memory, disk):
    """Persist a metrics snapshot to PostgreSQL."""
    conn = get_db_connection()
    if conn:
        try:
            cur = conn.cursor()
            cur.execute(
                "INSERT INTO metrics (cpu_percent, memory_percent, disk_percent) VALUES (%s, %s, %s)",
                (cpu, memory, disk),
            )
            conn.commit()
            cur.close()
            conn.close()
        except Exception as exc:
            logger.error("Failed to save metrics: %s", exc)


def get_cached_metrics():
    """Try to get system metrics from Redis cache."""
    client = get_redis_client()
    if client:
        try:
            cached = client.get("system_metrics")
            if cached:
                return json.loads(cached)
        except Exception:
            pass
    return None


def set_cached_metrics(data, ttl=10):
    """Store system metrics in Redis cache with a TTL (seconds)."""
    client = get_redis_client()
    if client:
        try:
            client.setex("system_metrics", ttl, json.dumps(data))
        except Exception:
            pass

# ---------------------------------------------------------------------------
# Collect system metrics
# ---------------------------------------------------------------------------

def collect_system_metrics():
    """Gather CPU, memory, and disk metrics from the host."""
    cpu = psutil.cpu_percent(interval=0.1)
    memory = psutil.virtual_memory().percent
    disk = psutil.disk_usage("/").percent

    # Update Prometheus gauges
    SYSTEM_CPU.set(cpu)
    SYSTEM_MEMORY.set(memory)
    SYSTEM_DISK.set(disk)

    return {"cpu_percent": cpu, "memory_percent": memory, "disk_percent": disk}

# ---------------------------------------------------------------------------
# Flask app factory
# ---------------------------------------------------------------------------

def create_app():
    """Application factory – creates and configures the Flask app."""
    app = Flask(__name__)
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY") or secrets.token_urlsafe(32)

    # Initialise database table on first request flag
    _db_initialized = {"done": False}

    @app.before_request
    def _before():
        request._start_time = time.time()
        if not _db_initialized["done"]:
            init_db()
            _db_initialized["done"] = True

    @app.after_request
    def _after(response):
        latency = time.time() - getattr(request, "_start_time", time.time())
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.path,
            http_status=response.status_code,
        ).inc()
        REQUEST_LATENCY.labels(endpoint=request.path).observe(latency)
        return response

    # ------------------------------------------------------------------
    # Health check endpoint
    # ------------------------------------------------------------------
    @app.route("/health")
    def health():
        """Simple health-check endpoint."""
        logger.info("Health check requested")
        return jsonify({
            "status": "healthy",
            "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
            "uptime_seconds": round(time.time() - APP_START_TIME, 2),
        })

    # ------------------------------------------------------------------
    # Prometheus metrics endpoint
    # ------------------------------------------------------------------
    @app.route("/metrics")
    def metrics():
        """Expose Prometheus-compatible metrics."""
        # Refresh gauges before scrape
        collect_system_metrics()
        return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

    # ------------------------------------------------------------------
    # System info API
    # ------------------------------------------------------------------
    @app.route("/api/system-info")
    def system_info():
        """Return detailed system information as JSON."""
        # Try cache first
        cached = get_cached_metrics()
        if cached:
            logger.info("Returning cached metrics")
            return jsonify(cached)

        metrics_data = collect_system_metrics()
        uptime = round(time.time() - APP_START_TIME, 2)

        data = {
            "hostname": platform.node(),
            "platform": platform.system(),
            "platform_version": platform.version(),
            "architecture": platform.machine(),
            "cpu_percent": metrics_data["cpu_percent"],
            "memory": {
                "total_gb": round(psutil.virtual_memory().total / (1024 ** 3), 2),
                "used_percent": metrics_data["memory_percent"],
            },
            "disk": {
                "total_gb": round(psutil.disk_usage("/").total / (1024 ** 3), 2),
                "used_percent": metrics_data["disk_percent"],
            },
            "uptime_seconds": uptime,
            "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
        }

        # Cache and persist
        set_cached_metrics(data)
        save_metrics(
            metrics_data["cpu_percent"],
            metrics_data["memory_percent"],
            metrics_data["disk_percent"],
        )

        logger.info("System info collected and returned")
        return jsonify(data)

    # ------------------------------------------------------------------
    # Simple HTML dashboard (root page)
    # ------------------------------------------------------------------
    @app.route("/")
    def index():
        """Render a minimal HTML dashboard."""
        return render_template_string(DASHBOARD_HTML)

    return app

# ---------------------------------------------------------------------------
# Minimal HTML template for the dashboard
# ---------------------------------------------------------------------------

DASHBOARD_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Health Dashboard</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #1a1a2e; color: #eee; margin: 0; padding: 20px; }
        h1 { color: #00d2ff; }
        .card { background: #16213e; border-radius: 10px; padding: 20px; margin: 10px 0; }
        .metric { font-size: 2em; color: #00d2ff; }
        .label { font-size: 0.9em; color: #aaa; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; }
        .status-ok { color: #00ff88; }
        a { color: #00d2ff; }
    </style>
</head>
<body>
    <h1>&#128154; Health Dashboard</h1>
    <p>System monitoring powered by Flask &amp; Prometheus</p>
    <div class="grid" id="metrics">Loading...</div>
    <p style="margin-top:20px">
        <a href="/health">/health</a> |
        <a href="/metrics">/metrics</a> |
        <a href="/api/system-info">/api/system-info</a>
    </p>
    <script>
        async function load() {
            try {
                const r = await fetch('/api/system-info');
                const d = await r.json();
                document.getElementById('metrics').innerHTML = `
                    <div class="card"><div class="label">CPU Usage</div><div class="metric">${d.cpu_percent}%</div></div>
                    <div class="card"><div class="label">Memory Usage</div><div class="metric">${d.memory.used_percent}%</div></div>
                    <div class="card"><div class="label">Disk Usage</div><div class="metric">${d.disk.used_percent}%</div></div>
                    <div class="card"><div class="label">Uptime</div><div class="metric">${Math.round(d.uptime_seconds)}s</div></div>
                    <div class="card"><div class="label">Host</div><div class="metric" style="font-size:1em">${d.hostname}</div></div>
                    <div class="card"><div class="label">Status</div><div class="metric status-ok">HEALTHY</div></div>
                `;
            } catch(e) { document.getElementById('metrics').innerHTML = '<p>Error loading metrics</p>'; }
        }
        load();
        setInterval(load, 5000);
    </script>
</body>
</html>
"""

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    app = create_app()
    port = int(os.getenv("APP_PORT", 5000))
    logger.info("Starting Health Dashboard on port %s", port)
    app.run(host="0.0.0.0", port=port, debug=os.getenv("FLASK_DEBUG", "false").lower() == "true")
