"""
Unit tests for the Health Dashboard Flask application.
Author: Vitalii Zaburdaiev | DevOpsUA6
"""

import json


def test_index_returns_200(client):
    """Test that the root page returns HTTP 200."""
    response = client.get("/")
    assert response.status_code == 200


def test_index_contains_html(client):
    """Test that the root page returns valid HTML content."""
    response = client.get("/")
    assert b"Health Dashboard" in response.data


def test_health_endpoint_returns_200(client):
    """Test that /health returns HTTP 200."""
    response = client.get("/health")
    assert response.status_code == 200


def test_health_response_structure(client):
    """Test that /health returns the correct JSON structure."""
    response = client.get("/health")
    data = json.loads(response.data)
    assert "status" in data
    assert "timestamp" in data
    assert "uptime_seconds" in data
    assert data["status"] == "healthy"


def test_health_status_is_healthy(client):
    """Test that /health reports a healthy status."""
    response = client.get("/health")
    data = json.loads(response.data)
    assert data["status"] == "healthy"
