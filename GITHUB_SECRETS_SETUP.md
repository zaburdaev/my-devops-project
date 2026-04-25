# GitHub Secrets Configuration

## Required secrets for CI/CD

### Docker Hub (build + push)
- `DOCKER_USERNAME` — Docker Hub username
- `DOCKER_PASSWORD` — Docker Hub password or access token

### Server deploy (SSH)
- `SERVER_HOST` — server public IP / DNS
- `SERVER_USER` — SSH user (`ec2-user` for Amazon Linux)
- `SSH_PRIVATE_KEY` — private key in PEM format

## Option 1: Web UI (recommended)

1. Open: https://github.com/zaburdaev/my-devops-project/settings/secrets/actions
2. Click **New repository secret**
3. Add:
   - `DOCKER_USERNAME` = `oskalibriya`
   - `DOCKER_PASSWORD` = `4da7CB1234/`

## Option 2: GitHub CLI

```bash
# login once
gh auth login

# set secrets
echo "oskalibriya" | gh secret set DOCKER_USERNAME --repo zaburdaev/my-devops-project
echo "4da7CB1234/" | gh secret set DOCKER_PASSWORD --repo zaburdaev/my-devops-project
```

## Verify secrets

```bash
gh secret list --repo zaburdaev/my-devops-project
```

Expected entries:

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `SERVER_HOST`
- `SERVER_USER`
- `SSH_PRIVATE_KEY`

## Re-run failed workflow

1. Open: https://github.com/zaburdaev/my-devops-project/actions
2. Select failed run
3. Click **Re-run all jobs**

## Current status (completed)

`DOCKER_USERNAME` and `DOCKER_PASSWORD` have already been added to repository secrets using GitHub CLI.
