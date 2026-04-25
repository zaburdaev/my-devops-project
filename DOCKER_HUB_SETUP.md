# 🐳 Docker Hub GitHub Secrets Setup

## Problem

GitHub Actions fails with:

```text
Error: Username and password required
```

## Solution: Add Docker Hub credentials to GitHub Secrets

### Step 1: Open repository secrets

1. Open: https://github.com/zaburdaev/my-devops-project
2. Click **Settings**
3. Go to **Secrets and variables** → **Actions**

### Step 2: Add `DOCKER_USERNAME`

1. Click **New repository secret**
2. Name: `DOCKER_USERNAME`
3. Value: `oskalibriya`
4. Click **Add secret**

### Step 3: Add `DOCKER_PASSWORD`

1. Click **New repository secret**
2. Name: `DOCKER_PASSWORD`
3. Value: `4da7CB1234/`
4. Click **Add secret**

### Step 4: Verify secrets

Expected secrets list should include:

- ✅ `DOCKER_USERNAME`
- ✅ `DOCKER_PASSWORD`
- ✅ `SERVER_HOST`
- ✅ `SERVER_USER`
- ✅ `SSH_PRIVATE_KEY`

### Step 5: Re-run pipeline

1. Open: https://github.com/zaburdaev/my-devops-project/actions
2. Open failed workflow run
3. Click **Re-run all jobs**

Pipeline should pass Docker login stage after this.

---

## Optional fallback (if Docker Hub is not needed)

You can temporarily skip Docker Hub push and make deploy depend only on tests (`needs: test`), then build images directly on server in deploy step with:

```bash
docker compose up -d --build
```

Use this only as a temporary workaround.
