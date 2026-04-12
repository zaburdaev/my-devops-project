"""
WSGI entry point for production deployment with Gunicorn.
Usage: gunicorn app.wsgi:app -b 0.0.0.0:5000
"""

from app.app import create_app

app = create_app()
