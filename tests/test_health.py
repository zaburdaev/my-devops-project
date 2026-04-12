"""
Endpoint tests for the Health Dashboard.
Author: Vitalii Zaburdaiev | DevOpsUA6
"""

import json


def test_system_info_returns_200(client):
    """Test that /api/system-info returns HTTP 200."""
    response = client.get("/api/system-info")
    assert response.status_code == 200


def test_system_info_has_cpu(client):
    """Test that /api/system-info includes CPU data."""
    response = client.get("/api/system-info")
    data = json.loads(response.data)
    assert "cpu_percent" in data
    assert isinstance(data["cpu_percent"], (int, float))


def test_system_info_has_memory(client):
    """Test that /api/system-info includes memory data."""
    response = client.get("/api/system-info")
    data = json.loads(response.data)
    assert "memory" in data
    assert "used_percent" in data["memory"]
    assert "total_gb" in data["memory"]


def test_system_info_has_disk(client):
    """Test that /api/system-info includes disk data."""
    response = client.get("/api/system-info")
    data = json.loads(response.data)
    assert "disk" in data
    assert "used_percent" in data["disk"]
    assert "total_gb" in data["disk"]


def test_metrics_endpoint_returns_200(client):
    """Test that /metrics returns HTTP 200 with Prometheus data."""
    response = client.get("/metrics")
    assert response.status_code == 200
    # Prometheus metrics contain HELP and TYPE lines
    assert b"system_cpu_usage_percent" in response.data


def test_system_info_has_hostname(client):
    """Test that /api/system-info includes hostname."""
    response = client.get("/api/system-info")
    data = json.loads(response.data)
    assert "hostname" in data


def test_system_info_has_uptime(client):
    """Test that /api/system-info includes uptime."""
    response = client.get("/api/system-info")
    data = json.loads(response.data)
    assert "uptime_seconds" in data
    assert data["uptime_seconds"] >= 0
