# 📖 DOCUMENTATION INDEX

> Навигационный индекс документации проекта `my-devops-project`  
> Updated: 2026-04-25

## Core Project Docs

- `README.md` — main overview (EN)
- `README_RU.md` — main overview (RU)
- `CONTRIBUTING.md` — contribution rules
- `LICENSE` — license terms

## Technical Docs (EN)

- `docs/GETTING_STARTED.md`
- `docs/ARCHITECTURE.md`
- `docs/DEPLOYMENT.md`
- `docs/CI_CD.md`
- `docs/MONITORING.md`
- `docs/TESTING.md`
- `docs/PROJECT_CHECKLIST.md`

## Technical / Operational Docs (RU)

- `COMPLETE_GUIDE_FOR_NON_IT_RU.md` — максимально подробное руководство для не-IT специалиста
- `docs/BEGINNER_GUIDE_RU.md`
- `docs/DEMO_SCRIPT_RU.md`
- `docs/AWS_DEPLOYMENT_RU.md`
- `docs/INFRASTRUCTURE_RECOVERY_RU.md`
- `docs/DISASTER_RECOVERY_RU.md`
- `docs/TROUBLESHOOTING_RU.md`
- `docs/QUICK_FIX_RU.md`
- `docs/MINIMAL_SETUP_RU.md`
- `docs/MONITORING_SIMPLE_RU.md`
- `docs/SECURITY_BEST_PRACTICES.md`

## Status / Audit / Summary Docs

- `DEPLOYMENT_SUMMARY.md`
- `FINAL_SETUP_SUMMARY.md`
- `SUCCESS_REPORT.md`
- `FINAL_INSTRUCTIONS_RU.md`
- `RECOVERY_AND_ACCESS_SUMMARY.md`
- `SECURITY_AUDIT.md`
- `SECURITY_AUDIT_REPORT.md`
- `GITHUB_SETUP.md`
- `DOCUMENTATION_SUMMARY.md`
- `DOCUMENTATION_STATUS.md`
- `DOCUMENTATION_AUDIT.md`

## Presentation Planning (Internal Markdown)

- `presentation/layout_plan/common_guidelines.md`
- `presentation/layout_plan/image_requirements.md`
- `presentation/layout_plan/slide_01_plan.md` ... `slide_12_plan.md`

## Current Architecture Baseline (for all docs)

- Docker Compose services: **6** (`app`, `postgres`, `redis`, `nginx`, `prometheus`, `grafana`)
- Loki: **removed from runtime stack**
- Logs: `docker compose logs`
- Prometheus scrape/eval interval: `60s`
- Public AWS IP: `18.156.160.162`
- Grafana credentials source: `.env` (`GF_SECURITY_ADMIN_USER` / `GF_SECURITY_ADMIN_PASSWORD`)
