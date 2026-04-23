# 🏥 Health Monitoring Dashboard

[![CI/CD Pipeline](https://github.com/zaburdaev/my-devops-project/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/zaburdaev/my-devops-project/actions/workflows/ci-cd.yml)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://hub.docker.com/r/oskalibriya/health-dashboard)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5?logo=kubernetes&logoColor=white)](./k8s/)
[![Terraform](https://img.shields.io/badge/Terraform-AWS-7B42BC?logo=terraform)](./terraform/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](./requirements.txt)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

> **Автор:** Виталий Забурдаев  
> **Курс:** DevOpsUA6  
> **Docker Hub:** [oskalibriya/health-dashboard](https://hub.docker.com/r/oskalibriya/health-dashboard)  
> **AWS:** Развёрнут на `3.127.155.114`  
> **Описание:** Полноценный DevOps-проект: дашборд мониторинга системного здоровья на Flask, контейнеризация Docker, оркестрация Kubernetes, инфраструктура Terraform, конфигурация Ansible, мониторинг Prometheus + Grafana + Loki.

🌍 [English version](./README.md)

---

## 📋 Содержание

- [О проекте](#-о-проекте)
- [Стек технологий](#-стек-технологий)
- [Возможности](#-возможности)
- [Быстрый старт](#-быстрый-старт)
- [Структура проекта](#-структура-проекта)
- [Документация](#-документация)
- [API-эндпоинты](#-api-эндпоинты)
- [Мониторинг](#-мониторинг)
- [Тестирование](#-тестирование)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Текущее состояние проекта](#-текущее-состояние-проекта)
- [Лицензия](#-лицензия)

---

## 🎯 О проекте

**Health Monitoring Dashboard** — веб-приложение для мониторинга системных метрик в реальном времени, демонстрирующее полный цикл DevOps:

**разработка → тестирование → контейнеризация → CI/CD → провижининг инфраструктуры → управление конфигурацией → деплой → мониторинг**

### Что делает приложение

Дашборд собирает и отображает системные метрики:

- 🖥️ **CPU Usage** — текущая загрузка процессора
- 🧠 **Memory Usage** — использование оперативной памяти
- 💾 **Disk Usage** — использование дискового пространства
- ⏱️ **Uptime** — время работы приложения
- 🏥 **Health Status** — общий статус здоровья системы

### Зачем создан

Проект создан как курсовой проект DevOpsUA6 для демонстрации владения современными DevOps-инструментами и практиками.

---

## 🛠️ Стек технологий

| Категория | Технология | Назначение |
|-----------|-----------|------------|
| 🐍 **Backend** | Flask (Python 3.11) | REST API и веб-интерфейс |
| 🐳 **Контейнеризация** | Docker & Docker Compose | Контейнеризация и оркестрация |
| 🗄️ **База данных** | PostgreSQL 15 | Хранение метрик |
| ⚡ **Кэширование** | Redis 7 | Кэширование данных |
| 🌐 **Веб-сервер** | Nginx | Обратный прокси |
| 📊 **Мониторинг** | Prometheus + Grafana | Метрики и визуализация |
| 📝 **Логирование** | Loki | Агрегация структурированных логов |
| 🔄 **CI/CD** | GitHub Actions | Автоматическое тестирование, сборка, деплой |
| 🏗️ **IaC** | Terraform (AWS) | Провижининг инфраструктуры (EC2, SG) |
| ⚙️ **Конфигурация** | Ansible | Настройка сервера и деплой |
| ☸️ **Оркестрация** | Kubernetes + Helm | Оркестрация контейнеров |

---

## ✨ Возможности

- ✅ **Многосервисная архитектура** — Flask + PostgreSQL + Redis + Nginx
- ✅ **Docker Compose** — полный стек одной командой
- ✅ **CI/CD пайплайн** — автоматический test → build → deploy
- ✅ **Infrastructure as Code** — Terraform провижинит AWS-ресурсы
- ✅ **Ansible** — автоматическая настройка сервера
- ✅ **Kubernetes** — манифесты + Helm chart для K8s деплоя
- ✅ **Мониторинг** — Prometheus + Grafana + Loki
- ✅ **Тесты** — 12 unit-тестов + линтинг
- ✅ **Безопасность** — non-root контейнер, секреты, заголовки безопасности
- ✅ **AWS деплой** — развёрнут на EC2 (3.127.155.114)

---

## 🚀 Быстрый старт

### Предварительные требования

- Docker & Docker Compose
- Git
- Python 3.11+ (для локальной разработки)

### Запуск

```bash
# 1. Клонировать репозиторий
git clone https://github.com/zaburdaev/my-devops-project.git
cd my-devops-project

# 2. Скопировать файл окружения
cp .env.example .env

# 3. Собрать и запустить
make deploy
# или
docker-compose up -d --build

# 4. Открыть в браузере
# Дашборд:  http://localhost
# Grafana:  http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090
```

---

## 📚 Документация

### На английском

| Документ | Описание |
|----------|----------|
| 📖 [Getting Started](./docs/GETTING_STARTED.md) | Пошаговая инструкция по настройке |
| 🏗️ [Architecture](./docs/ARCHITECTURE.md) | Архитектура системы |
| 🚀 [Deployment](./docs/DEPLOYMENT.md) | Все варианты деплоя (Docker, AWS, K8s, Ansible) |
| 🔄 [CI/CD](./docs/CI_CD.md) | Описание CI/CD пайплайна |
| 📊 [Monitoring](./docs/MONITORING.md) | Мониторинг: Prometheus, Grafana, Loki |
| 🧪 [Testing](./docs/TESTING.md) | Стратегия тестирования |
| ✅ [Project Checklist](./docs/PROJECT_CHECKLIST.md) | Чеклист проекта (240 баллов) |

### На русском 🇷🇺

| Документ | Описание |
|----------|----------|
| 📘 [Руководство для начинающих](./docs/BEGINNER_GUIDE_RU.md) | Полное руководство с объяснением всех технологий |
| 🎬 [Сценарий демонстрации](./docs/DEMO_SCRIPT_RU.md) | Пошаговый скрипт для защиты проекта |
| ☁️ [AWS деплой](./docs/AWS_DEPLOYMENT_RU.md) | Подробная инструкция по развёртыванию на AWS |
| ♻️ [Восстановление инфраструктуры](./docs/INFRASTRUCTURE_RECOVERY_RU.md) | Полный recovery runbook (RU) |
| 🚀 [Итоги деплоя](./DEPLOYMENT_SUMMARY.md) | Сводка развёрнутой инфраструктуры |
| 🔒 [Аудит безопасности](./SECURITY_AUDIT.md) | Результаты проверки безопасности |
| 📋 [Статус документации](./DOCUMENTATION_STATUS.md) | Полный статус всей документации |

---

## 🔌 API-эндпоинты

| Метод | Эндпоинт | Описание |
|-------|----------|----------|
| `GET` | `/` | HTML-дашборд |
| `GET` | `/health` | Проверка здоровья (JSON) |
| `GET` | `/metrics` | Метрики Prometheus |
| `GET` | `/api/system-info` | Информация о системе (JSON) |

---

## 📊 Мониторинг

- **Prometheus** (`:9090`) — сбор метрик каждые 10 секунд
- **Grafana** (`:3000`) — предустановленный дашборд (CPU, память, диск)
- **Loki** (`:3100`) — структурированные JSON-логи
- **Алерты** — CPU > 80%, память > 85%, приложение недоступно

---

## 🧪 Тестирование

```bash
# Локальные тесты
make test

# Тесты в Docker
make test-docker

# Линтинг
make lint
```

---

## 🔄 CI/CD Pipeline

GitHub Actions пайплайн (`ci-cd.yml`) запускается при каждом push/PR в `main`:

1. **🧪 Test** → pytest (12 тестов) + flake8 линтинг
2. **🐳 Build** → Сборка Docker-образа, push на Docker Hub
3. **🚀 Deploy** → SSH на сервер, pull образа, перезапуск сервисов

---

## 🌐 Текущее состояние проекта

| Компонент | Статус |
|-----------|--------|
| **AWS EC2** | ✅ Развёрнут (3.127.155.114) |
| **CI/CD Pipeline** | ✅ Работает (GitHub Actions) |
| **Docker Hub** | ✅ Образ опубликован |
| **Тесты** | ✅ 12/12 пройдены |
| **Документация** | ✅ Полная (EN + RU) |
| **Безопасность** | ✅ Аудит пройден |

### Ссылки на развёрнутое приложение

| Сервис | URL |
|--------|-----|
| Health Dashboard | http://3.127.155.114 |
| Grafana | http://3.127.155.114:3000 |
| Prometheus | http://3.127.155.114:9090 |

### Elastic IP (статический IP)

Проект использует **AWS Elastic IP** `3.127.155.114`, поэтому внешний IP остаётся стабильным даже при пересоздании EC2.

```bash
cd terraform
terraform output -raw elastic_ip
```

### Восстановление инфраструктуры через GitHub Actions

1. GitHub → **Actions** → **Infrastructure Recovery**
2. Нажать **Run workflow**
3. Workflow выполнит `terraform apply`, получит `elastic_ip`, обновит `SERVER_HOST` и выполнит деплой

Workflow файл: [`.github/workflows/infrastructure-recovery.yml`](./.github/workflows/infrastructure-recovery.yml)

---

## 📄 Лицензия

Проект распространяется под лицензией MIT — см. файл [LICENSE](./LICENSE).

---

## 📬 Контакты

- **Автор:** Виталий Забурдаев
- **Курс:** DevOpsUA6
- **GitHub:** [github.com/zaburdaev](https://github.com/zaburdaev)
- **Проект:** [github.com/zaburdaev/my-devops-project](https://github.com/zaburdaev/my-devops-project)

---

<p align="center">
  Создано с ❤️ <strong>Виталий Забурдаев</strong> | DevOpsUA6
</p>
