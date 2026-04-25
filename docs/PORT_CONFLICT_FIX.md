# Port Conflict Resolution

## Problem

When running `docker compose up`, you get:

```text
Error: ports are not available: exposing port TCP 0.0.0.0:5000
bind: address already in use
```

## Root Cause

Port 5000 is already used by another application on your machine.

Common culprits on macOS:
- AirPlay Receiver (macOS Monterey+)
- Another Flask/Python app
- Control Center services

## Solutions

### Solution 1: Use Nginx Instead (Recommended)

The app is designed to work via Nginx on port 80.

**You DON'T need port 5000!**

```bash
# Just start without override file
docker compose up -d

# Access via Nginx
curl http://localhost/health
```

✅ **This is how it works in production on AWS!**

### Solution 2: Free Port 5000

#### On macOS (Disable AirPlay Receiver)

1. Open **System Preferences**
2. Go to **Sharing**
3. Uncheck **AirPlay Receiver**
4. Restart Docker

#### On macOS (Kill Process)

```bash
# Find what's using port 5000
lsof -i :5000

# Kill the process (replace PID with actual number)
kill -9 <PID>
```

#### On Linux

```bash
# Find process
sudo lsof -i :5000

# Kill it
sudo kill -9 <PID>
```

#### On Windows

```cmd
# Find process
netstat -ano | findstr :5000

# Kill it (replace PID)
taskkill /PID <PID> /F
```

### Solution 3: Don't Expose Port 5000

**Remove the override file (if you created it):**

```bash
rm docker-compose.override.yml
docker compose down
docker compose up -d
```

Access only via Nginx (port 80).

## Understanding the Architecture

```text
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │ Port 80
       ▼
┌─────────────┐
│    Nginx    │ ← Reverse Proxy
└──────┬──────┘
       │ Internal Docker Network
       ▼
┌─────────────┐
│  Flask App  │ Port 5000 (internal only)
└─────────────┘
```

**Production Setup (AWS):**
- ✅ Nginx: Public (port 80)
- ❌ Flask: Internal only (no port exposure)

**Local Development (Recommended):**
- ✅ Nginx: http://localhost
- ❌ Flask: Internal (same as production)

**Local Development (Optional):**
- ✅ Nginx: http://localhost
- ✅ Flask: http://localhost:5000 (via override file)

## Verification

After fixing:

```bash
# Start services
docker compose up -d

# Check all containers are running
docker compose ps

# Test via Nginx
curl http://localhost/health

# Should return:
# {"status":"healthy"}
```

## When to Expose Port 5000

✅ **Expose port 5000 when:**
- Debugging Flask directly
- Testing without Nginx
- Local API development

❌ **Don't expose port 5000 when:**
- Running in production
- Port 5000 conflicts with other apps
- Following production-like setup locally
