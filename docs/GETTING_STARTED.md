# 🚀 Getting Started Guide

Welcome! This guide will walk you through setting up the **Health Monitoring Dashboard** on your local machine, step by step. No prior DevOps experience is required — we'll explain everything along the way. 😊

---

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [Step 1: Install Required Software](#-step-1-install-required-software)
- [Step 2: Clone the Repository](#-step-2-clone-the-repository)
- [Step 3: Configure Environment Variables](#-step-3-configure-environment-variables)
- [Step 4: Build and Run with Docker Compose](#-step-4-build-and-run-with-docker-compose)
- [Step 5: Access the Application](#-step-5-access-the-application)
- [Step 6: Run Tests](#-step-6-run-tests)
- [Common Commands](#-common-commands)
- [Troubleshooting](#-troubleshooting)

---

## 📦 Prerequisites

Before you begin, you need to install these tools on your computer:

| Tool | Version | Why You Need It |
|------|---------|----------------|
| **Git** | 2.30+ | To download (clone) the project code from GitHub |
| **Docker** | 20.0+ | To run the application and all its services in containers |
| **Docker Compose** | 2.0+ | To start all 7 services at once with a single command |
| **Python** | 3.11+ | *(Optional)* Only needed if you want to run tests locally without Docker |

> 💡 **What is Docker?** Docker is a tool that packages applications and their dependencies into "containers" — lightweight, portable environments that run the same everywhere. Think of it like a shipping container for software.

> 💡 **What is Docker Compose?** Docker Compose lets you define and run multiple Docker containers together. Our project has 7 services, and Docker Compose starts them all with one command.

---

## 📥 Step 1: Install Required Software

### Install Git

**Windows:**
1. Download Git from [git-scm.com](https://git-scm.com/download/win)
2. Run the installer and follow the prompts (default settings are fine)
3. Verify: Open Command Prompt and type `git --version`

**macOS:**
```bash
# Using Homebrew (recommended)
brew install git

# Verify installation
git --version
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install git -y

# Verify installation
git --version
```

### Install Docker & Docker Compose

**Windows & macOS:**
1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Install and start Docker Desktop
3. Docker Compose comes bundled with Docker Desktop

**Linux (Ubuntu/Debian):**
```bash
# Install Docker
sudo apt update
sudo apt install docker.io -y

# Start Docker and enable it on boot
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to the docker group (so you don't need sudo every time)
sudo usermod -aG docker $USER

# Log out and log back in for group changes to take effect

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Verify installations
docker --version
docker compose version
```

### Verify Everything Is Installed

Run these commands to make sure everything is ready:

```bash
git --version        # Should show something like: git version 2.40.0
docker --version     # Should show something like: Docker version 24.0.0
docker compose version  # Should show something like: Docker Compose version v2.20.0
```

> ⚠️ **If any command fails**, make sure the software is installed and your terminal/command prompt is restarted.

---

## 📂 Step 2: Clone the Repository

"Cloning" means downloading the project code from GitHub to your computer.

```bash
# Navigate to where you want to put the project
cd ~/projects  # or any folder you prefer

# Clone the repository
git clone https://github.com/zaburdaev/my-devops-project.git

# Enter the project folder
cd my-devops-project
```

> 💡 **What just happened?** Git downloaded all the project files from GitHub to a new folder called `my-devops-project` on your computer.

You should see a folder structure like this:

```
my-devops-project/
├── app/              # The Flask application
├── tests/            # Unit tests
├── nginx/            # Nginx configuration
├── monitoring/       # Prometheus, Grafana, Loki configs
├── terraform/        # AWS infrastructure code
├── ansible/          # Server automation
├── k8s/              # Kubernetes manifests
├── docker-compose.yml
├── Dockerfile
├── Makefile
└── ...
```

---

## ⚙️ Step 3: Configure Environment Variables

Environment variables are settings that configure how the application and its services behave. We use a `.env` file to store them.

### 3.1 Create the .env File

```bash
# Copy the example file to create your own .env file
cp .env.example .env
```

> 💡 **Why copy instead of rename?** We keep `.env.example` in Git as a template. The actual `.env` file is in `.gitignore` so your real passwords never get uploaded to GitHub.

### 3.2 Review the .env File

Open `.env` in any text editor. Here's what each variable does:

```bash
# === Flask Application ===
FLASK_DEBUG=0                    # Set to 1 for development mode (shows errors in detail)
SECRET_KEY=your-secret-key-here  # Used for security (sessions, cookies). Change in production!
APP_PORT=5000                    # Port the Flask app runs on inside the container

# === PostgreSQL Database ===
POSTGRES_HOST=postgres           # Hostname of the database (matches service name in docker-compose)
POSTGRES_PORT=5432               # Default PostgreSQL port
POSTGRES_DB=health_dashboard     # Name of the database
POSTGRES_USER=postgres           # Database username
POSTGRES_PASSWORD=postgres123    # Database password. CHANGE THIS in production!

# === Redis Cache ===
REDIS_HOST=redis                 # Hostname of Redis (matches service name in docker-compose)
REDIS_PORT=6379                  # Default Redis port

# === Grafana ===
GF_SECURITY_ADMIN_USER=admin    # Grafana login username
GF_SECURITY_ADMIN_PASSWORD=admin # Grafana login password
```

> ⚠️ **For local development**, the default values are fine. For production, **always change passwords!**

---

## 🐳 Step 4: Build and Run with Docker Compose

Now let's start all services! This single command will:
- Build the Flask application Docker image
- Start all 7 services (app, PostgreSQL, Redis, Nginx, Prometheus, Grafana, Loki)
- Create a network so services can communicate with each other
- Set up persistent data volumes

### Option A: Using Make (Recommended)

```bash
make deploy
```

> 💡 **What is Make?** Make is a build automation tool. The `Makefile` in the project defines shortcuts for common commands, so you don't have to type long Docker commands.

### Option B: Using Docker Compose Directly

```bash
docker-compose up -d --build
```

Let's break this command down:
- `docker-compose up` — Start all the services defined in `docker-compose.yml`
- `-d` — Run in "detached" mode (in the background, so you get your terminal back)
- `--build` — Rebuild the Docker images before starting (picks up any code changes)

### Wait for Services to Start

The first time you run this, Docker needs to download base images (PostgreSQL, Redis, Nginx, etc.). This may take **2-5 minutes** depending on your internet speed.

Check that all services are running:

```bash
# Using Make
make ps

# Or using Docker Compose
docker-compose ps
```

You should see all 7 services with status "Up" or "healthy":

```
NAME                STATUS
app                 Up (healthy)
postgres            Up (healthy)
redis               Up (healthy)
nginx               Up
prometheus          Up
grafana             Up
loki                Up
```

---

## 🌐 Step 5: Access the Application

Once all services are running, open your web browser and visit:

| Service | URL | What You'll See |
|---------|-----|----------------|
| 🏥 **Dashboard** | [http://localhost](http://localhost) | Main health monitoring page (via Nginx) |
| 🔧 **Flask API** | [http://localhost:5000](http://localhost:5000) | Direct access to the Flask app |
| 🔧 **Health Check** | [http://localhost:5000/health](http://localhost:5000/health) | JSON health status |
| 🔧 **System Info** | [http://localhost:5000/api/system-info](http://localhost:5000/api/system-info) | Detailed system metrics (JSON) |
| 📈 **Prometheus** | [http://localhost:9090](http://localhost:9090) | Metrics query interface |
| 📊 **Grafana** | [http://localhost:3000](http://localhost:3000) | Monitoring dashboards (login: admin/admin) |

### First Time in Grafana

1. Open [http://localhost:3000](http://localhost:3000)
2. Login with **admin** / **admin**
3. When prompted to change password, you can skip or set a new one
4. Go to **Dashboards** → **Browse** → **Health Dashboard**
5. You should see live CPU, memory, and disk usage charts! 📊

---

## 🧪 Step 6: Run Tests

### Option A: Run Tests with Docker (No Python Required)

```bash
make test-docker
```

This builds a temporary container and runs all 12 tests inside it.

### Option B: Run Tests Locally (Requires Python)

```bash
# Create a virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run tests
make test
# or
pytest tests/ -v
```

You should see output like:

```
tests/test_app.py::test_index_returns_200 PASSED
tests/test_app.py::test_index_contains_html PASSED
tests/test_app.py::test_health_endpoint_returns_200 PASSED
tests/test_app.py::test_health_response_structure PASSED
tests/test_app.py::test_health_status_is_healthy PASSED
tests/test_health.py::test_system_info_returns_200 PASSED
tests/test_health.py::test_system_info_has_cpu PASSED
...

========== 12 passed ==========
```

---

## 📝 Common Commands

Here's a cheat sheet of the most useful commands:

### Docker Compose Commands

| Command | What It Does |
|---------|-------------|
| `make deploy` | Build and start all services |
| `make down` | Stop and remove all services |
| `make restart` | Restart all services |
| `make logs` | View logs from all services |
| `make ps` | Show status of all services |
| `make clean` | Remove everything (containers, volumes, images) |

### Testing Commands

| Command | What It Does |
|---------|-------------|
| `make test` | Run tests locally with pytest |
| `make test-docker` | Run tests in a Docker container |
| `make lint` | Check code style with flake8 |

### Terraform Commands

| Command | What It Does |
|---------|-------------|
| `make tf-init` | Initialize Terraform |
| `make tf-plan` | Preview infrastructure changes |
| `make tf-apply` | Create AWS infrastructure |
| `make tf-destroy` | Destroy AWS infrastructure |

### Kubernetes Commands

| Command | What It Does |
|---------|-------------|
| `make k8s-deploy` | Deploy to Kubernetes cluster |
| `make k8s-delete` | Remove from Kubernetes cluster |
| `make helm-install` | Deploy using Helm chart |
| `make helm-uninstall` | Remove Helm release |

---

## 🔧 Troubleshooting

### ❌ "Docker daemon is not running"

**Problem:** Docker is not started on your machine.

**Solution:**
- **Windows/macOS:** Open Docker Desktop application
- **Linux:** Run `sudo systemctl start docker`

### ❌ "Port 80 is already in use"

**Problem:** Another application (like Apache or another web server) is using port 80.

**Solution:**
```bash
# Find what's using port 80
sudo lsof -i :80  # macOS/Linux
netstat -ano | findstr :80  # Windows

# Stop the conflicting service, or change the port in docker-compose.yml
```

### ❌ "Permission denied" when running Docker

**Problem:** Your user doesn't have permission to use Docker.

**Solution:**
```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Log out and log back in, then try again
```

### ❌ Container is "Exiting" or "Unhealthy"

**Problem:** A service failed to start properly.

**Solution:**
```bash
# Check the logs of the failing service
docker-compose logs app       # Check the Flask app
docker-compose logs postgres  # Check the database
docker-compose logs redis     # Check Redis

# Common fix: restart everything
make down
make deploy
```

### ❌ "Cannot connect to PostgreSQL" in app logs

**Problem:** The database hasn't finished starting before the app tries to connect.

**Solution:** This usually resolves itself — the app has retry logic. Wait 30 seconds and check again. If it persists:

```bash
# Restart just the app
docker-compose restart app
```

### ❌ Tests fail with "ModuleNotFoundError"

**Problem:** Python dependencies are not installed.

**Solution:**
```bash
pip install -r requirements.txt
```

### ❌ Grafana shows "No data"

**Problem:** Prometheus hasn't scraped enough metrics yet, or datasource is misconfigured.

**Solution:**
1. Wait 30-60 seconds for Prometheus to collect data
2. Check Prometheus targets: [http://localhost:9090/targets](http://localhost:9090/targets) — all targets should be "UP"
3. Grafana datasources should be auto-configured — if not, check `monitoring/grafana/provisioning/`

---

## ⏭️ What's Next?

Now that you have the project running locally, explore these guides:

- 🏗️ [Architecture](./ARCHITECTURE.md) — Understand how all the pieces fit together
- 🚀 [Deployment](./DEPLOYMENT.md) — Deploy to AWS, Kubernetes, or with Ansible
- 🔄 [CI/CD](./CI_CD.md) — Understand the automated pipeline
- 📊 [Monitoring](./MONITORING.md) — Deep dive into Prometheus & Grafana
- 🧪 [Testing](./TESTING.md) — Learn about the testing strategy

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>
