# 🔧 Quick Fix: Port 5000 Conflict

## Your Error

```text
Error: bind: address already in use (port 5000)
```

## Quick Solution (2 minutes)

### Step 1: Update Code

```bash
cd ~/my-devops-project
git pull origin main
```

### Step 2: Start Containers

```bash
docker compose down
docker compose up -d
```

### Step 3: Test

```bash
# Open in browser
http://localhost/health

# Should show: {"status":"healthy"}
```

## ✅ Done!

You don't need port 5000!
- Access app via Nginx: `http://localhost`
- Everything works the same way

## Want Port 5000? (Optional)

First, free the port on your Mac:

**Disable AirPlay Receiver:**
1. System Preferences → Sharing
2. Uncheck "AirPlay Receiver"

**Then:**

```bash
cp docker-compose.override.yml.example docker-compose.override.yml
docker compose down
docker compose up -d
```

Now: `http://localhost:5000` works!
