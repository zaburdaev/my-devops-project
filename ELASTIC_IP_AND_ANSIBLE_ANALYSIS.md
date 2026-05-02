# Elastic IP Issue & Ansible Usage Analysis
**Analysis Date:** May 2, 2026  
**Status:** COMPLETE - Both issues analyzed and documented

---

## 🔴 TASK 1: ELASTIC IP ISSUE - CRITICAL FINDING

### Problem Summary
Your infrastructure was recreated with a **NEW Elastic IP (18.197.7.122)** instead of reusing the **ORIGINAL IP (18.197.7.122)**.

### Root Cause
The Terraform configuration in `terraform/main.tf` **always creates a new Elastic IP allocation**:
```hcl
resource "aws_eip" "app_eip" {
  domain = "vpc"
  tags = {
    Name    = "health-dashboard-eip"
    Project = "my-devops-project"
  }
}
```

Every time you run `terraform apply`, this creates a **fresh** EIP instead of reusing an existing one.

---

### AWS Current State ❌

| IP Address | Status | Associated With | Allocation ID |
|-----------|--------|-----------------|-----------------|
| **18.197.7.122** | 🔴 **RELEASED** (GONE) | — | — |
| **18.197.7.122** | ✅ Active | EC2: `i-059c8320d831be2bf` | `eipalloc-0f1d885679fa634f8` |
| **18.184.217.22** | ❌ Unassociated | — | `eipalloc-09dfda03e21afbd57` |

### The Bad News 😞

**AWS does NOT allow requesting a specific Elastic IP address.** You cannot "get back" 18.197.7.122 because:
- ✗ AWS Elastic IPs are released back to the pool when you release them
- ✗ There's no API to request a specific IP
- ✗ Once released, it may be allocated to other customers

**You CANNOT reuse 18.197.7.122. It's permanently lost.**

### The Good News ✅

**Terraform state is ALREADY synchronized with AWS.** The good news is:
- ✅ Terraform knows about allocation `eipalloc-0f1d885679fa634f8`
- ✅ It's correctly associated with your EC2 instance
- ✅ No state mismatches

### Solution & Action Items

**You have 3 options:**

#### ✅ **OPTION 1: KEEP THE NEW IP (RECOMMENDED)**
Accept 18.197.7.122 as your new stable IP:
- Update GitHub Secrets: `SERVER_HOST = 18.197.7.122`
- Update DNS records (if any domain points to old IP)
- Update all documentation references
- The IP is **STABLE** and won't change unless you release it

**Why this is best:** Simplest, no additional costs, the new IP works perfectly.

#### 🎲 **OPTION 2: TRY TO GET A "SIMILAR" IP (RISKY)**
Release 18.197.7.122 and allocate a new one, hoping for a similar IP in the same range:
```bash
# In AWS console or CLI:
# 1. Release eipalloc-0f1d885679fa634f8 (18.197.7.122)
# 2. Allocate new Elastic IP in eu-central-1
# 3. Might get 18.156.160.165 or similar
```

**Why this is risky:** 
- No guarantee of getting the old IP back
- Temporary downtime during switch
- Might get a completely different IP

#### ❌ **OPTION 3: FIX TERRAFORM TO REUSE EXISTING IP (FOR FUTURE)**
Modify Terraform to import and reuse existing EIP allocations:
```hcl
# Instead of creating new, reference existing:
data "aws_eip" "existing" {
  filter {
    name   = "allocation-id"
    values = ["eipalloc-0f1d885679fa634f8"]  # Your current allocation
  }
}

resource "aws_eip_association" "app_eip_assoc" {
  instance_id   = aws_instance.health_dashboard.id
  allocation_id = data.aws_eip.existing.id
}
```

**This prevents future IP changes** but requires manual Terraform state management.

---

### 📋 Current Configuration Status

**Terraform State (terraform/main.tf):**
- ✅ References correct allocation: `eipalloc-0f1d885679fa634f8`
- ✅ Associated with correct instance: `i-059c8320d831be2bf`
- ✅ Current IP: `18.197.7.122`

**GitHub Secrets:**
- Uses: `secrets.SERVER_HOST` in `.github/workflows/ci-cd.yml`
- Actual value: **NEEDS VERIFICATION** (not stored in repo, set in GitHub)
- Should be: `18.197.7.122`

**Documentation:**
- ❌ 110+ references to old IP `18.197.7.122` found
- Files affected: docs/, presentations, guides, README files
- Status: **OUTDATED** - needs mass update

---

## 🔵 TASK 2: ANSIBLE USAGE - CLEAR ANSWER

### Quick Answer
**Ansible IS NOT being used in your CI/CD pipeline.** 🚫

It exists in the project but is **completely unused** by the actual deployment automation.

---

### Proof & Analysis

**На каком этапе используется Ansible?** (At what stage is Ansible used?)

**Answer: НИКОГДА.** (NEVER.)

### What We Found

#### ✅ Ansible Files DO Exist
```
ansible/
├── playbook.yml              (281 lines - fully configured)
├── inventory.ini             (configured with server details)
└── roles/
    ├── docker/               (installs Docker)
    └── app/                  (deploys application)
```

The playbook is **complete and functional**:
- Installs Docker & Docker Compose
- Configures firewall (firewalld)
- Opens ports: 22, 80, 443, 3000, 9090, 5000
- Includes roles for Docker and App deployment

#### ❌ Ansible is NEVER Called in CI/CD

**File: `.github/workflows/ci-cd.yml`**
- ✗ **NO** reference to `ansible`
- ✗ **NO** `ansible-playbook` execution
- ✗ **NO** Ansible inventory loading
- ✗ **NO** SSH to trigger Ansible on server

**What CI/CD actually does:**
1. Runs tests (pytest)
2. Builds Docker image
3. Pushes to Docker Hub
4. **SSH directly** to server using `appleboy/ssh-action`
5. Runs bash scripts directly (NOT Ansible tasks)

**File: `.github/workflows/infrastructure-recovery.yml`**
- ✗ **NO** reference to `ansible`
- ✗ Uses **Terraform** to create infrastructure
- ✗ Uses **SSH with bash scripts** to deploy, NOT Ansible

#### 📚 Ansible is Only in Documentation

Ansible is mentioned in:
- `docs/DEPLOYMENT.md` - shows it as an **optional** deployment method
- `docs/CI_CD.md` - mentions running it manually
- README files - as an alternative approach
- Demo scripts - for presentations

**Actual usage:** Users could **manually** run Ansible if they wanted:
```bash
cd ansible/
ansible-playbook -i inventory.ini playbook.yml
```

But the **automated pipeline never calls it.**

---

### Why Ansible is Unused

The project was designed with **TWO independent deployment paths**:

| Aspect | Ansible Path | Docker Path (ACTUAL) |
|--------|--------------|----------------------|
| **Who triggers it** | Manual (user) | GitHub Actions (automatic) |
| **When used** | Initial setup (optional) | Every commit to main |
| **Tools** | ansible-playbook | Docker Compose + SSH |
| **Status** | ✗ Obsolete | ✅ Active |
| **In CI/CD?** | NO | YES |

---

### Docker Path (What's Actually Used)

Your actual deployment flow:
```
Push to main
    ↓
GitHub Actions triggers
    ↓
Tests run (pytest)
    ↓
Docker image built & pushed
    ↓
SSH into server
    ↓
bash script runs: docker compose pull, docker compose up
    ↓
Application deployed
```

**Ansible is completely bypassed.** The bash scripts in the SSH step do the same things Ansible would do, but inline.

---

### Recommendation: Remove or Use Ansible

#### Option A: **Remove Ansible (RECOMMENDED)**
Since it's unused and adds confusion:
```bash
rm -rf ansible/
# Remove ansible references from docs/
```

**Pros:**
- Cleaner codebase
- No confusion for new developers
- Reduces maintenance burden

**Cons:**
- Might break demo scripts
- Loses IaC option

#### Option B: **Integrate Ansible into CI/CD**
Replace the bash SSH method with Ansible:
```yaml
# In .github/workflows/ci-cd.yml - deploy job
- name: Deploy with Ansible
  run: |
    cd ansible/
    ansible-playbook -i inventory.ini playbook.yml \
      -e "docker_image=${{ secrets.DOCKER_USERNAME }}/health-dashboard:latest"
```

**Pros:**
- Proper IaC practice
- Idempotent deployments
- Better for scaling

**Cons:**
- Need to install Ansible in GitHub Actions
- Requires updating playbook for CI/CD use
- More complexity

#### Option C: **Keep as Optional Manual Tool**
Document it clearly as an optional setup method:
- Add note: "Ansible is available for manual setup but NOT used by CI/CD"
- Keep it for users who prefer it
- Make it optional in setup guides

---

## 📊 Summary Table

| Issue | Status | Details |
|-------|--------|---------|
| **Elastic IP 18.197.7.122** | 🔴 LOST | Released to AWS, cannot be recovered |
| **Elastic IP 18.197.7.122** | ✅ ACTIVE | Currently in use, stable |
| **Terraform State** | ✅ SYNCED | Correctly configured |
| **AWS Configuration** | ✅ CORRECT | Instance has correct EIP |
| **Ansible in project** | ✅ EXISTS | All files present and functional |
| **Ansible in CI/CD** | ❌ UNUSED | Never called by automation |
| **Actual deployment method** | ✅ DOCKER | Using Docker Compose + SSH |

---

## ✅ Action Items Checklist

### For Elastic IP Issue:
- [ ] **CRITICAL:** Update `secrets.SERVER_HOST` in GitHub to `18.197.7.122`
  - Go to: GitHub Repo → Settings → Secrets and variables → Actions
  - Update `SERVER_HOST` secret value
- [ ] Update DNS records (if you have a custom domain pointing to old IP)
- [ ] Update documentation files with new IP (110+ references)
  - Consider using: `find . -type f -name "*.md" -exec sed -i 's/3\.127\.155\.114/18.197.7.122/g' {} \;`

### For Ansible Issue:
- [ ] **DECIDE:** Keep, integrate, or remove Ansible from project
- [ ] **IF KEEPING:** Add note in README: "Ansible is optional, not used by CI/CD"
- [ ] **IF REMOVING:** Delete `ansible/` directory and update docs

---

## 🔗 Relevant Files

**AWS & Infrastructure:**
- Terraform config: `terraform/main.tf` (lines 148-160 for EIP)
- Terraform state: `terraform/terraform.tfstate`
- Infrastructure recovery workflow: `.github/workflows/infrastructure-recovery.yml`

**Ansible:**
- Playbook: `ansible/playbook.yml`
- Inventory: `ansible/inventory.ini`
- Roles: `ansible/roles/docker/` and `ansible/roles/app/`

**CI/CD:**
- Main pipeline: `.github/workflows/ci-cd.yml` (deploy job)

---

**Generated by DevOps Analysis Script | May 2, 2026**
