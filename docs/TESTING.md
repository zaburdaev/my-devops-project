# 🧪 Testing Documentation

This guide explains the testing strategy for the **Health Monitoring Dashboard** — what tests exist, how to run them, and how to add new ones.

---

## 📋 Table of Contents

- [Testing Strategy](#-testing-strategy)
- [Test Structure](#-test-structure)
- [How to Run Tests](#-how-to-run-tests)
- [Understanding the Tests](#-understanding-the-tests)
- [How to Add New Tests](#-how-to-add-new-tests)
- [Test Coverage](#-test-coverage)
- [CI/CD Integration](#-cicd-integration)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Testing Strategy

Our testing strategy focuses on **unit testing** the Flask API endpoints to ensure they:

1. ✅ Return the correct HTTP status codes
2. ✅ Return properly structured JSON responses
3. ✅ Include all expected data fields
4. ✅ Return correct data types
5. ✅ Provide meaningful health check information

> 💡 **What is unit testing?** Unit tests check individual components (or "units") of your code in isolation. They're fast, reliable, and catch bugs early. Think of them as a safety net — if you change code and a test breaks, you know something went wrong.

---

## 📂 Test Structure

```
tests/
├── __init__.py        # Makes tests/ a Python package
├── conftest.py        # Shared fixtures (test setup)
├── test_app.py        # Tests for main app endpoints (/, /health)
└── test_health.py     # Tests for /api/system-info and /metrics
```

### conftest.py — Shared Test Setup

This file contains **fixtures** — reusable pieces of test setup that are shared across all test files.

```python
# tests/conftest.py

import pytest
from app.app import create_app

@pytest.fixture
def app():
    """Create a Flask application for testing.
    
    Why: Each test needs a fresh Flask app instance
    to avoid tests interfering with each other.
    """
    app = create_app()
    app.config['TESTING'] = True  # Enable test mode
    return app

@pytest.fixture
def client(app):
    """Create a test client for making HTTP requests.
    
    Why: The test client lets us simulate HTTP requests
    (GET, POST, etc.) without starting a real server.
    """
    return app.test_client()
```

> 💡 **What is a fixture?** A fixture is a function that provides test data or setup. When a test function has a parameter named `client`, pytest automatically calls the `client` fixture and passes the result.

---

## ▶️ How to Run Tests

### Option 1: Run Locally (Requires Python)

```bash
# 1. Create a virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run all tests
pytest tests/ -v
```

### Option 2: Using Make

```bash
# Run tests locally
make test

# Run tests in Docker (no Python required on your machine)
make test-docker
```

### Option 3: Run Specific Tests

```bash
# Run a specific test file
pytest tests/test_app.py -v

# Run a specific test function
pytest tests/test_app.py::test_health_endpoint_returns_200 -v

# Run tests matching a pattern
pytest tests/ -v -k "health"
```

### Understanding the Output

```
tests/test_app.py::test_index_returns_200 PASSED            ✅
tests/test_app.py::test_index_contains_html PASSED           ✅
tests/test_app.py::test_health_endpoint_returns_200 PASSED   ✅
tests/test_app.py::test_health_response_structure PASSED     ✅
tests/test_app.py::test_health_status_is_healthy PASSED      ✅
tests/test_health.py::test_system_info_returns_200 PASSED    ✅
tests/test_health.py::test_system_info_has_cpu PASSED        ✅
tests/test_health.py::test_system_info_has_memory PASSED     ✅
tests/test_health.py::test_system_info_has_disk PASSED       ✅
tests/test_health.py::test_system_info_has_hostname PASSED   ✅
tests/test_health.py::test_system_info_has_uptime PASSED     ✅
tests/test_health.py::test_metrics_endpoint_returns_200 PASSED ✅

========================= 12 passed =========================
```

- **PASSED** ✅ — The test succeeded
- **FAILED** ❌ — The test found a bug (look at the error message for details)
- **ERROR** 💥 — The test itself has a problem (import error, syntax error, etc.)

---

## 🔍 Understanding the Tests

### test_app.py — Main Application Tests (5 tests)

| Test | What It Checks | Why It's Important |
|------|---------------|-------------------|
| `test_index_returns_200` | `GET /` returns HTTP 200 | The main page should always be accessible |
| `test_index_contains_html` | Response contains HTML content | The dashboard page should render properly |
| `test_health_endpoint_returns_200` | `GET /health` returns HTTP 200 | Health checks are used by Docker and K8s |
| `test_health_response_structure` | Response has `status`, `timestamp`, `uptime_seconds` | Monitoring tools expect a specific format |
| `test_health_status_is_healthy` | Status field equals `"healthy"` | Confirms the app is working correctly |

#### Example: Health Endpoint Test

```python
def test_health_response_structure(client):
    """Verify that /health returns the expected JSON structure.
    
    Why: Docker health checks, Kubernetes probes, and monitoring
    tools all rely on this endpoint having a consistent structure.
    """
    response = client.get('/health')
    data = response.get_json()
    
    # Check that all required fields exist
    assert 'status' in data          # Should be "healthy"
    assert 'timestamp' in data       # ISO format datetime
    assert 'uptime_seconds' in data  # How long app has been running
```

### test_health.py — System Info & Metrics Tests (7 tests)

| Test | What It Checks | Why It's Important |
|------|---------------|-------------------|
| `test_system_info_returns_200` | `GET /api/system-info` returns HTTP 200 | API endpoint must be accessible |
| `test_system_info_has_cpu` | Response includes CPU percentage | Core monitoring metric |
| `test_system_info_has_memory` | Response includes memory info | Core monitoring metric |
| `test_system_info_has_disk` | Response includes disk info | Core monitoring metric |
| `test_system_info_has_hostname` | Response includes hostname | Identifies the server |
| `test_system_info_has_uptime` | Response includes uptime | Shows how long app has been running |
| `test_metrics_endpoint_returns_200` | `GET /metrics` returns Prometheus data | Prometheus needs this endpoint |

#### Example: System Info Test

```python
def test_system_info_has_cpu(client):
    """Verify that /api/system-info includes CPU usage data.
    
    Why: CPU usage is one of the core metrics displayed
    on the dashboard and monitored by Prometheus.
    """
    response = client.get('/api/system-info')
    data = response.get_json()
    
    assert 'cpu_percent' in data              # Field exists
    assert isinstance(data['cpu_percent'], (int, float))  # Is a number
```

---

## ➕ How to Add New Tests

### Step 1: Decide What to Test

Ask yourself:
- What endpoint/function am I testing?
- What's the expected behavior?
- What could go wrong?

### Step 2: Write the Test

Create a new file or add to an existing one:

```python
# tests/test_new_feature.py

def test_my_endpoint_returns_200(client):
    """Test that GET /api/my-endpoint returns HTTP 200.
    
    Why: This endpoint provides [explanation of what it does].
    It should always be accessible and return a valid response.
    """
    response = client.get('/api/my-endpoint')
    assert response.status_code == 200

def test_my_endpoint_response_format(client):
    """Test that the response has the expected JSON structure.
    
    Why: Client applications depend on a consistent response format.
    """
    response = client.get('/api/my-endpoint')
    data = response.get_json()
    
    assert 'result' in data
    assert isinstance(data['result'], str)

def test_my_endpoint_with_invalid_input(client):
    """Test that invalid input returns an appropriate error.
    
    Why: The API should handle bad input gracefully
    instead of crashing.
    """
    response = client.get('/api/my-endpoint?bad=true')
    assert response.status_code in [400, 422]
```

### Step 3: Run the Tests

```bash
# Run your new tests
pytest tests/test_new_feature.py -v

# Run ALL tests to make sure you didn't break anything
pytest tests/ -v
```

### Step 4: Commit

```bash
git add tests/test_new_feature.py
git commit -m "test: add tests for new endpoint"
```

### Testing Best Practices

| Practice | Why |
|----------|-----|
| **One assert per test** (ideally) | Makes it clear what failed |
| **Descriptive test names** | `test_health_status_is_healthy` not `test1` |
| **Add docstrings** | Explain what the test checks and why |
| **Test edge cases** | Empty input, missing fields, wrong types |
| **Keep tests independent** | Each test should work on its own |
| **Don't test external services** | Mock databases, APIs, etc. |

---

## 📊 Test Coverage

Test coverage measures how much of your code is executed by tests. Higher coverage means fewer untested code paths.

### Run Tests with Coverage

```bash
# Install coverage tool
pip install pytest-cov

# Run tests with coverage report
pytest tests/ -v --cov=app --cov-report=term-missing
```

### Sample Output

```
Name          Stmts   Miss  Cover   Missing
--------------------------------------------
app/app.py      85     23    73%    45-50, 78-85, 102-110
app/wsgi.py      3      0   100%
--------------------------------------------
TOTAL            88     23    74%
```

- **Stmts** — Total lines of code
- **Miss** — Lines not covered by tests
- **Cover** — Percentage of code covered
- **Missing** — Line numbers not covered

### What We Test

| Component | Tested? | Coverage |
|-----------|:-------:|:--------:|
| `GET /` (dashboard) | ✅ | HTTP status + content |
| `GET /health` | ✅ | Status, structure, values |
| `GET /api/system-info` | ✅ | All fields + types |
| `GET /metrics` | ✅ | HTTP status + content |
| Database connection | ⚠️ | Partially (error handling) |
| Redis caching | ⚠️ | Partially (error handling) |

---

## 🔄 CI/CD Integration

Tests run automatically in the CI/CD pipeline on every push and pull request.

### How It Works

1. You push code to GitHub
2. GitHub Actions triggers the `test` job
3. The job:
   - Sets up Python 3.11
   - Installs dependencies
   - Runs `pytest tests/ -v`
   - Runs `flake8` (code style check)
4. If tests pass ✅ → Build and Deploy jobs can proceed
5. If tests fail ❌ → Pipeline stops, no deployment

### View Test Results

1. Go to [GitHub → Actions](https://github.com/zaburdaev/my-devops-project/actions)
2. Click on a workflow run
3. Click on the **"test"** job
4. Expand the **"Run pytest"** step to see test output

---

## 🔧 Troubleshooting

### ❌ "ModuleNotFoundError: No module named 'app'"

**Problem:** Python can't find the application module.

**Solution:**
```bash
# Make sure you're in the project root directory
cd my-devops-project

# Make sure conftest.py adds the project to sys.path
# (This is already done in the project's conftest.py)
```

### ❌ "ModuleNotFoundError: No module named 'flask'"

**Problem:** Dependencies are not installed.

**Solution:**
```bash
pip install -r requirements.txt
```

### ❌ Tests pass locally but fail in CI

**Possible causes:**
- Different Python version
- Missing dependency in `requirements.txt`
- Environment-specific behavior

**Solution:**
```bash
# Test with Python 3.11 (same as CI)
python3.11 -m pytest tests/ -v

# Make sure all imports are in requirements.txt
```

### ❌ "Connection refused" errors in tests

**Problem:** Tests are trying to connect to PostgreSQL or Redis.

**Solution:** The test fixtures use `TESTING = True` which should bypass external connections. If you're getting connection errors, the test is likely an integration test that needs running services. Use `make test-docker` instead.

---

## 📖 Related Documentation

- 🚀 [Getting Started](./GETTING_STARTED.md) — Set up the project
- 🔄 [CI/CD](./CI_CD.md) — How tests run in the pipeline
- 🏗️ [Architecture](./ARCHITECTURE.md) — System overview

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>
