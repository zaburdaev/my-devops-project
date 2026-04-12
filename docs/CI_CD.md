# 🔄 CI/CD Documentation

This guide explains the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the **Health Monitoring Dashboard** project.

---

## 📋 Table of Contents

- [What Is CI/CD?](#-what-is-cicd)
- [Our Pipeline Overview](#-our-pipeline-overview)
- [Pipeline Stages](#-pipeline-stages)
- [GitHub Actions Workflow File](#-github-actions-workflow-file)
- [How to View Workflow Runs](#-how-to-view-workflow-runs)
- [How to Add New Tests](#-how-to-add-new-tests)
- [How to Configure Secrets](#-how-to-configure-secrets)
- [Troubleshooting](#-troubleshooting)

---

## 💡 What Is CI/CD?

**CI/CD** stands for **Continuous Integration** and **Continuous Deployment** (or Delivery). It's a practice of automating the steps between writing code and deploying it to production.

### Continuous Integration (CI)

Every time you push code to GitHub:
1. Tests run automatically ✅
2. Code is checked for style issues ✅
3. If anything fails, you get notified ❌

> 💡 **Why?** To catch bugs early, before they reach production. If tests pass, you can be more confident your code works.

### Continuous Deployment (CD)

If CI passes and code is on the `main` branch:
1. A Docker image is built automatically 🐳
2. The image is pushed to Docker Hub 📦
3. The application is deployed to the server 🚀

> 💡 **Why?** To automate repetitive tasks. Instead of manually building and deploying every time, the pipeline does it for you — faster and without human errors.

---

## 🗺️ Our Pipeline Overview

```
┌──────────────────────────────────────────────────────────┐
│                  GitHub Actions Pipeline                   │
│                                                           │
│  Trigger: Push to main / Pull Request to main             │
│                                                           │
│  ┌─────────┐    ┌─────────┐    ┌──────────┐              │
│  │  TEST   │───▶│  BUILD  │───▶│  DEPLOY  │              │
│  │         │    │         │    │          │              │
│  │ pytest  │    │ Docker  │    │ SSH to   │              │
│  │ flake8  │    │ build   │    │ server   │              │
│  │         │    │ push to │    │ restart  │              │
│  │         │    │ DockerHub│    │ services │              │
│  └─────────┘    └─────────┘    └──────────┘              │
│                                                           │
│  Runs on       Only on         Only on                    │
│  ALL events    push to main    push to main               │
└──────────────────────────────────────────────────────────┘
```

**Key points:**
- **Test** runs on every push and every pull request
- **Build** only runs on pushes to `main` (not on PRs)
- **Deploy** only runs after Build succeeds
- Each stage depends on the previous one — if Test fails, Build never runs

---

## 📝 Pipeline Stages

### Stage 1: 🧪 Test

**When it runs:** On every push to `main` AND on every pull request to `main`

**What it does:**

```yaml
steps:
  1. Checks out the code from GitHub
  2. Sets up Python 3.11
  3. Installs dependencies from requirements.txt
  4. Runs pytest (12 unit tests)
  5. Runs flake8 (code style checker)
```

**Why this matters:** Ensures that no broken code gets merged into the main branch. The tests verify:
- All API endpoints return correct HTTP status codes
- Response JSON has the expected structure
- The health endpoint reports "healthy"
- System info contains CPU, memory, disk, hostname, and uptime data
- The `/metrics` endpoint works for Prometheus

**If this stage fails:** The Build and Deploy stages will NOT run. Fix the failing test before merging.

### Stage 2: 🐳 Build

**When it runs:** Only on pushes to `main` (not on pull requests), and only after Test passes

**What it does:**

```yaml
steps:
  1. Checks out the code
  2. Logs into Docker Hub (using stored secrets)
  3. Builds the Docker image using the multi-stage Dockerfile
  4. Tags the image with:
     - "latest" tag
     - Git commit SHA tag (e.g., "abc123f")
  5. Pushes both tags to Docker Hub
```

**Why this matters:** Creates a ready-to-deploy Docker image. The commit SHA tag lets you trace exactly which code version is running in production.

**Docker Hub image:** [`oskalibriya/health-dashboard`](https://hub.docker.com/r/oskalibriya/health-dashboard)

### Stage 3: 🚀 Deploy

**When it runs:** Only on pushes to `main`, and only after Build passes

**What it does:**

```yaml
steps:
  1. Checks if deployment secrets are configured (skips gracefully if not)
  2. Connects to the server via SSH
  3. Creates /opt/health-dashboard directory if it doesn't exist
  4. On first deploy: clones the repository from GitHub
  5. On subsequent deploys: pulls the latest changes via git pull
  6. Creates .env file from .env.example if it doesn't exist
  7. Pulls the latest Docker images
  8. Restarts Docker Compose services
  9. Shows service status
```

**Why this matters:** Automatically deploys new code to the server without manual intervention. The deployment script handles both initial (first-time) and subsequent deployments automatically — no need to manually set up the server directory beforehand.

> ⚠️ **Note:** The Deploy stage requires a running server and configured SSH access. Without these, the step is gracefully skipped — this is expected for development/educational setups.
>
> 💡 **Tip:** Alternatively, you can run the Ansible playbook first to prepare the server:
> ```bash
> cd ansible
> ansible-playbook -i inventory.ini playbook.yml
> ```

---

## 📄 GitHub Actions Workflow File

The pipeline is defined in `.github/workflows/ci-cd.yml`. Here's what each section does:

```yaml
# File: .github/workflows/ci-cd.yml

name: CI/CD Pipeline  # Name shown in GitHub Actions UI

# TRIGGERS: When should this pipeline run?
on:
  push:
    branches: [ main ]        # Run on pushes to main
  pull_request:
    branches: [ main ]        # Run on PRs targeting main

jobs:
  # JOB 1: Run tests
  test:
    runs-on: ubuntu-latest    # Use a fresh Ubuntu machine
    steps:
      - uses: actions/checkout@v3           # Download the code
      - uses: actions/setup-python@v4       # Install Python 3.11
        with:
          python-version: '3.11'
      - run: pip install -r requirements.txt # Install dependencies
      - run: pytest tests/ -v               # Run tests
      - run: flake8 app/ tests/             # Check code style

  # JOB 2: Build Docker image
  build:
    needs: test               # Only run if test passes
    if: github.event_name == 'push'  # Only on push (not PRs)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: docker/login-action@v2       # Log into Docker Hub
        with:
          username: oskalibriya
          password: ${{ secrets.DOCKER_HUB_TOKEN }}
      - uses: docker/build-push-action@v4  # Build and push image
        with:
          push: true
          tags: |
            oskalibriya/health-dashboard:latest
            oskalibriya/health-dashboard:${{ github.sha }}

  # JOB 3: Deploy to server (handles first deploy automatically)
  deploy:
    needs: build              # Only run if build passes
    if: github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - name: Check deployment secrets    # Skip if not configured
      - uses: appleboy/ssh-action@v1      # SSH into server
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            sudo mkdir -p /opt/health-dashboard
            if [ ! -d "/opt/health-dashboard/.git" ]; then
              cd /opt && sudo git clone <repo-url> health-dashboard
              sudo chown -R $(whoami):$(whoami) /opt/health-dashboard
            else
              cd /opt/health-dashboard && git pull origin main
            fi
            cd /opt/health-dashboard
            [ ! -f ".env" ] && cp .env.example .env
            docker-compose pull
            docker-compose up -d
```

---

## 👀 How to View Workflow Runs

### Step 1: Go to GitHub Actions

1. Open the repository: [github.com/zaburdaev/my-devops-project](https://github.com/zaburdaev/my-devops-project)
2. Click the **"Actions"** tab at the top

### Step 2: View a Workflow Run

1. You'll see a list of all workflow runs with their status:
   - ✅ Green checkmark = all jobs passed
   - ❌ Red X = one or more jobs failed
   - 🟡 Yellow circle = running
2. Click on any run to see details

### Step 3: View Job Logs

1. Click on a specific job (Test, Build, or Deploy)
2. Click on any step to expand its logs
3. You can see the exact output of each command

---

## ➕ How to Add New Tests

### Step 1: Create a Test File

Add a new test file in the `tests/` directory or add tests to existing files:

```python
# tests/test_new_feature.py

def test_my_new_endpoint(client):
    """Test that my new endpoint works correctly."""
    response = client.get('/api/my-new-endpoint')
    assert response.status_code == 200
    
    data = response.get_json()
    assert 'result' in data
```

### Step 2: Use the `client` Fixture

The `client` fixture (defined in `tests/conftest.py`) gives you a test client for making HTTP requests to the Flask app:

```python
def test_example(client):
    # Make a GET request
    response = client.get('/health')
    
    # Check status code
    assert response.status_code == 200
    
    # Parse JSON response
    data = response.get_json()
    
    # Check response content
    assert data['status'] == 'healthy'
```

### Step 3: Run Tests Locally

```bash
# Run all tests
pytest tests/ -v

# Run a specific test file
pytest tests/test_new_feature.py -v

# Run a specific test
pytest tests/test_new_feature.py::test_my_new_endpoint -v
```

### Step 4: Push Your Changes

```bash
git add tests/test_new_feature.py
git commit -m "test: add tests for new feature"
git push
```

The CI pipeline will automatically run your new tests! 🎉

---

## 🔐 How to Configure Secrets

GitHub Secrets are encrypted environment variables that your workflow can use. They keep sensitive data (like passwords and API keys) secure.

### Required Secrets

| Secret Name | Purpose | Where to Get It |
|-------------|---------|----------------|
| `DOCKER_HUB_TOKEN` | Authenticate with Docker Hub | [Docker Hub Settings](https://hub.docker.com/settings/security) |
| `SERVER_HOST` | IP address of deployment server | Terraform output or cloud console |
| `SERVER_USER` | SSH username for the server | Usually `ec2-user` for AWS |
| `SSH_PRIVATE_KEY` | Private SSH key for the server | Your SSH key file |
| `AWS_ACCESS_KEY_ID` | AWS credentials (for Terraform) | AWS IAM Console |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials (for Terraform) | AWS IAM Console |

### How to Add a Secret

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Enter the **Name** and **Value**
5. Click **"Add secret"**

> ⚠️ **Security:** Once a secret is saved, you can't view it again — only update or delete it. Secrets are never exposed in workflow logs.

---

## 🔧 Troubleshooting

### ❌ Tests Fail in CI but Pass Locally

**Common causes:**
- Missing dependencies in `requirements.txt`
- Tests depend on environment-specific settings
- Different Python version locally vs CI

**Solution:**
```bash
# Make sure you test with the same Python version
python3.11 -m pytest tests/ -v

# Check that all imports are in requirements.txt
pip freeze > requirements_check.txt
```

### ❌ Build Fails with "Unauthorized"

**Problem:** Docker Hub credentials are wrong or expired.

**Solution:**
1. Go to [Docker Hub Security Settings](https://hub.docker.com/settings/security)
2. Create a new access token
3. Update the `DOCKER_HUB_TOKEN` secret in GitHub

### ❌ Deploy Fails with "Connection Refused"

**Problem:** The server is not reachable or SSH is misconfigured.

**Solution:**
1. Verify the server is running (check AWS console or `terraform output`)
2. Check `SERVER_HOST` secret has the correct IP
3. Check `SSH_PRIVATE_KEY` secret has the full private key (including `-----BEGIN` and `-----END` lines)
4. Make sure port 22 is open in the security group

### ❌ Deploy Fails with "No Such Directory"

**Problem:** The application directory `/opt/health-dashboard` doesn't exist on the server (common on first deployment).

**This issue has been fixed!** The deployment script now automatically:
1. Creates the directory if it doesn't exist (`sudo mkdir -p /opt/health-dashboard`)
2. Clones the repository on first deploy
3. Pulls updates on subsequent deploys

**If you still encounter this issue**, SSH into the server and set up manually:
```bash
ssh -i key.pem ec2-user@your-server-ip
sudo mkdir -p /opt/health-dashboard
cd /opt
sudo git clone https://github.com/zaburdaev/my-devops-project.git health-dashboard
sudo chown -R ec2-user:ec2-user /opt/health-dashboard
cd /opt/health-dashboard
cp .env.example .env
docker-compose up -d --build
```

**Alternative:** Run Ansible playbook first to prepare the server:
```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

---

## 📖 Related Documentation

- 🚀 [Getting Started](./GETTING_STARTED.md) — Set up the project locally
- 🚀 [Deployment](./DEPLOYMENT.md) — Deployment options
- 🧪 [Testing](./TESTING.md) — Testing strategy and guide
- 📊 [Monitoring](./MONITORING.md) — Monitoring your deployment

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>
