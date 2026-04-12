"""
Pytest configuration and shared fixtures for Health Dashboard tests.
"""

import pytest
import sys
import os

# Add project root to path so we can import the app module
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.app import create_app


@pytest.fixture
def app():
    """Create a Flask application instance for testing."""
    application = create_app()
    application.config["TESTING"] = True
    return application


@pytest.fixture
def client(app):
    """Create a test client for the Flask application."""
    return app.test_client()
