# =============================================================================
# Multi-stage Dockerfile for Health Dashboard
# Author: Vitalii Zaburdaiev | DevOpsUA6
# Stage 1: Install dependencies
# Stage 2: Lightweight production image with non-root user
# =============================================================================

# ---------- Stage 1: Builder ----------
FROM python:3.11-slim AS builder

WORKDIR /build

# Install system dependencies required to compile Python packages (e.g. psutil)
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---------- Stage 2: Production ----------
FROM python:3.11-slim AS production

# Security: create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

WORKDIR /app

# Copy installed Python packages from builder stage
COPY --from=builder /install /usr/local

# Copy application code
COPY app/ ./app/
COPY requirements.txt .

# Set ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Run with Gunicorn for production
CMD ["gunicorn", "app.wsgi:app", "-b", "0.0.0.0:5000", "--workers", "2", "--access-logfile", "-"]
