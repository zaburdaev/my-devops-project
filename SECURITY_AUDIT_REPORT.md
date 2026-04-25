# SECURITY AUDIT REPORT

**Project:** `my-devops-project`  
**Audit date:** 2026-04-25  
**Auditor:** Abacus AI Agent

## Executive Summary

Проведен полный аудит безопасности по коду, IaC, контейнерной конфигурации, зависимостям и базовым эксплуатационным практикам.

### Ключевой результат
- **Обнаружены критичные риски конфигурации** (дефолтные пароли в compose/example-конфигах, открытые публичные порты, слабые дефолты в приложении, уязвимые Python-зависимости).
- **Часть критичных проблем исправлена безопасными low-risk изменениями** без изменения архитектуры и без принудительного остановa рабочих сервисов.
- **Часть рисков требует действий владельца инфраструктуры/GitHub** (branch protection, secret scanning, HTTPS на проде, ограничения Security Group).

### Что исправлено в рамках аудита
1. Обновлены уязвимые Python-пакеты в `requirements.txt`:
   - `Flask 3.0.0 -> 3.1.3`
   - `gunicorn 21.2.0 -> 22.0.0`
   - `pytest 7.4.3 -> 9.0.3`
   - `requests 2.31.0 -> 2.33.0`
2. Убраны hardcoded Grafana credentials из `docker-compose.yml` (переведено на env-переменные).
3. Усилены примеры секретов в `.env.example` (без `admin/admin` и `changeme`).
4. Усилен дефолт `SECRET_KEY` в Flask (`token_urlsafe(32)` при отсутствии env).
5. Убраны слабые примерные секреты в `k8s/secret.yaml` и Helm `values.yaml`.
6. Добавлен параметр Terraform `allowed_ssh_cidr` для ограничения SSH-доступа по whitelist IP.
7. Усилен `.gitignore` (добавлены `.env.local`, ключи/сертификаты, state-файлы и пр.).
8. Усилены локальные права на `.env` до `600`.

## Critical Issues (требуют немедленного исправления)

1. **Дефолтные/слабые credentials в конфигурациях**
   - Ранее: `GF_SECURITY_ADMIN_PASSWORD=admin`, `POSTGRES_PASSWORD=changeme`, `my-secret-key` в K8s/Helm.
   - Риск: компрометация мониторинга/БД при утечке конфигурации или ошибочной публикации.
   - **Статус:** ✅ Исправлено в tracked-файлах (`docker-compose.yml`, `.env.example`, `k8s/*`, `helm/values.yaml`).

2. **Уязвимые Python-зависимости (CVE)**
   - Найдены по результатам `safety`/`pip-audit`: Flask, gunicorn, pytest, requests.
   - Риск: request smuggling, disclosure/cache issues, локальные привилегии в тестовой среде и др.
   - **Статус:** ✅ Исправлено обновлением `requirements.txt`.

3. **Публичный доступ к административным/внутренним портам в Terraform SG**
   - `22`, `3000`, `9090`, `5000` открыты на `0.0.0.0/0`.
   - Риск: brute-force/сканирование/экспонирование внутренних сервисов.
   - **Статус:** ⚠️ Частично исправлено: для SSH добавлена переменная `allowed_ssh_cidr` (возможность hardening без ломки текущего деплоя).  
     Для портов `3000/9090/5000` требуется инфраструктурное решение владельца (см. Recommendations).

## High Priority Issues

1. **HTTPS/TLS не зафиксирован как обязательный слой для всех публичных endpoint'ов**
   - HTTP-поверхность присутствует, Grafana/Prometheus потенциально доступны без TLS.
   - **Статус:** ⚠️ Требует инфраструктурной донастройки (Nginx + Let's Encrypt/ACM).

2. **Prometheus без auth при потенциально публичном доступе**
   - **Статус:** ⚠️ Требуется включить auth/reverse-proxy policy и ограничить доступ по IP.

3. **Terraform output содержит приватный SSH ключ (`ssh_private_key`)**
   - Хоть output помечен `sensitive = true`, ключ попадает в state/операционные процессы.
   - **Статус:** ⚠️ Рекомендуется убрать output в production-профиле и хранить ключи во внешнем secret manager.

## Medium Priority Issues

1. **Локальный `.env` содержал шаблонные значения и имел права `644`**
   - **Статус:** ✅ Права ужесточены до `600`.
   - Примечание: фактическая ротация реальных production-секретов должна быть выполнена владельцем.

2. **Нет явной политики password rotation и secret rotation в репозитории**
   - **Статус:** ✅ Добавлен документ `docs/SECURITY_BEST_PRACTICES.md`.

3. **Невозможно автоматически верифицировать GitHub Security Settings без админ-доступа**
   - **Статус:** ⚠️ Требует ручной проверки владельцем репозитория.

## Low Priority Issues

1. **`safety check` использует deprecated команду**
   - Рекомендуется миграция на `safety scan`.
2. **В репозитории присутствует много вспомогательных артефактов (pdf/tfplan) вне основной кодовой поверхности**
   - Рекомендуется периодический housekeeping и правила retention.

## Recommendations

### 1) Секреты и credentials
- Немедленно задать реальные сильные значения для:
  - `SECRET_KEY`
  - `POSTGRES_PASSWORD`
  - `GF_SECURITY_ADMIN_PASSWORD`
- Включить ротацию (минимум раз в 90 дней или после инцидента).
- Перенести production secrets в AWS Secrets Manager / SSM Parameter Store / Vault.

### 2) Network hardening
- SSH: задать `allowed_ssh_cidr` равным вашему статическому IP (`x.x.x.x/32`).
- Закрыть публичные `5000`, `9090`, `3000` на уровне SG; публиковать только `80/443` через Nginx.
- Ограничить административные панели (Grafana/Prometheus) VPN или IP allowlist.

### 3) TLS / HTTPS
- Настроить HTTPS (Let's Encrypt + certbot, либо AWS ACM + ALB).
- Включить HTTP->HTTPS redirect.
- Добавить HSTS (после стабильной работы HTTPS).

### 4) GitHub repository security settings (manual)
Проверить и включить:
- Branch protection rules для `main`:
  - required PR reviews
  - required status checks
  - запрет force-push
- Secret scanning (включая push protection)
- Dependabot alerts + Dependabot security updates
- Code scanning (CodeQL)

### 5) Dependency security process
- Запуск `pip-audit` в CI на каждый PR.
- Еженедельный security job для dependency scan.
- Обновления зависимостей через PR с тестами.

## Compliance Checklist

- [x] Скан проекта на password/api_key/secret/token паттерны
- [x] Проверка AWS/GitHub token паттернов (`AKIA`, `github_pat_`)
- [x] Проверка `.env*` и `.gitignore`
- [x] Проверка git-истории по чувствительным путям/паттернам
- [x] Python dependency audit (`safety`, `pip-audit`)
- [x] Проверка наличия Node.js зависимостей (`package.json`)
- [x] Аудит Terraform Security Group и SSH-политики
- [x] Аудит Docker Compose / Dockerfile
- [x] Проверка дефолтных паролей Grafana/Postgres/K8s/Helm
- [x] Проверка прав на `.env` / `*.pem`
- [x] Подготовлены actionable recommendations
- [x] Внесены безопасные исправления в код/конфиги

## Action Items для владельца проекта (обязательно)

1. Задать и задеплоить **новые реальные** production credentials (не шаблонные).
2. Ограничить `allowed_ssh_cidr` до конкретного IP.
3. Закрыть SG-доступ к 3000/9090/5000 извне.
4. Включить HTTPS (Let's Encrypt/ACM) и редирект с 80 на 443.
5. Включить branch protection + secret scanning + Dependabot + CodeQL в GitHub.
6. Удалить/минимизировать output `ssh_private_key` из Terraform для production.
