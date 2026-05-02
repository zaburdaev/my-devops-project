# 🔧 Полное руководство: Пайплайны, Terraform и Ansible

**Автор:** Vitalii Zaburdaiev  
**Проект:** Health Dashboard | DevOpsUA6  
**Актуальный IP:** `18.156.160.162`  
**EC2 Instance:** `i-059c8320d831be2bf`

---

## 📚 Содержание

1. [Обзор архитектуры CI/CD](#1-обзор-архитектуры-cicd)
2. [Пайплайн ci-cd.yml — деплой с Ansible](#2-пайплайн-ci-cdyml--деплой-с-ansible)
3. [Пайплайн infrastructure-recovery.yml — восстановление с Terraform](#3-пайплайн-infrastructure-recoveryyml--восстановление-с-terraform)
4. [Terraform: что делает и как работает](#4-terraform-что-делает-и-как-работает)
5. [Ansible: что делает и как работает](#5-ansible-что-делает-и-как-работает)
6. [Terraform + Ansible: как дополняют друг друга](#6-terraform--ansible-как-дополняют-друг-друга)
7. [Когда использовать какой инструмент](#7-когда-использовать-какой-инструмент)
8. [Секреты GitHub Actions](#8-секреты-github-actions)
9. [Диаграммы и схемы](#9-диаграммы-и-схемы)

---

## 1. Обзор архитектуры CI/CD

В проекте используются **два независимых пайплайна** GitHub Actions:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     GITHUB ACTIONS PIPELINES                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ci-cd.yml (автоматический)                                        │
│  ─────────────────────────                                          │
│  Триггер: push в main                                              │
│  Цель: Деплой нового кода                                          │
│  Инструменты: Python, Docker, ANSIBLE                              │
│  Когда: Каждый коммит                                              │
│                                                                     │
│  infrastructure-recovery.yml (ручной)                              │
│  ────────────────────────────────────                                │
│  Триггер: workflow_dispatch (кнопка)                               │
│  Цель: Пересоздание ВСЕЙ инфраструктуры                           │
│  Инструменты: AWS CLI, TERRAFORM, SSH                              │
│  Когда: Сервер потерян / катастрофа                                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Пайплайн ci-cd.yml — деплой с Ansible

### 🎯 Назначение

Автоматический деплой приложения при каждом push в ветку `main`. Использует **Ansible** для управления конфигурацией сервера и деплоя.

### 📋 Пошаговый разбор

#### Stage 1: 🧪 Run Tests

```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - Checkout code              # Скачиваем код из репозитория
    - Set up Python 3.11         # Устанавливаем Python
    - Install dependencies       # pip install -r requirements.txt
    - Run tests                  # pytest tests/ -v --cov=app
```

**Что происходит:**
1. GitHub создаёт чистую Ubuntu VM
2. Клонирует репозиторий
3. Устанавливает Python 3.11 и зависимости
4. Запускает `pytest` с отчётом о покрытии кода
5. Если тесты FAIL → пайплайн ОСТАНАВЛИВАЕТСЯ, деплоя не будет

#### Stage 2: 🐳 Build and Push Docker Image

```yaml
build:
  needs: test                    # Зависит от Stage 1
  if: github.ref == 'refs/heads/main'  # Только для main
  steps:
    - Checkout code
    - Login to Docker Hub        # Используем DOCKER_USERNAME + DOCKER_PASSWORD
    - Build and push             # Собираем образ и пушим в Docker Hub
```

**Что происходит:**
1. Запускается ТОЛЬКО если тесты прошли (`needs: test`)
2. Запускается ТОЛЬКО для ветки `main` (не для PR)
3. Логинится в Docker Hub
4. Собирает Docker образ из `Dockerfile`
5. Пушит с двумя тегами:
   - `username/health-dashboard:latest` — всегда последний
   - `username/health-dashboard:<git-sha>` — конкретный коммит

#### Stage 3: 🚀 Deploy via Ansible

```yaml
deploy:
  needs: build                   # Зависит от Stage 2
  if: github.ref == 'refs/heads/main'
  steps:
    - Checkout code              # Нужен для ansible/ файлов
    - Set up Python              # Для установки Ansible
    - Install Ansible            # pip install ansible
    - Configure SSH key          # Сохраняем SSH_PRIVATE_KEY в ~/.ssh/
    - Generate Ansible inventory # Создаём inventory.ini с SERVER_HOST
    - Run Ansible Playbook       # ansible-playbook -i ... ansible/playbook.yml
    - Post-deploy verification   # curl проверки health/grafana/prometheus
```

**Что происходит шаг за шагом:**

1. **Checkout** — клонируем репозиторий, чтобы иметь доступ к `ansible/` директории
2. **Python + Ansible** — устанавливаем Ansible через pip
3. **SSH ключ** — сохраняем приватный ключ из GitHub Secrets в `~/.ssh/deploy_key`
4. **Динамический inventory** — генерируем файл `inventory.ini` с актуальным IP сервера:
   ```ini
   [webservers]
   production ansible_host=18.156.160.162 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/deploy_key
   ```
5. **Ansible Playbook** — запускаем плейбук, который:
   - Устанавливает Docker (если не установлен)
   - Клонирует/обновляет репозиторий на сервере
   - Генерирует `.env` из `.env.example`
   - Останавливает старые контейнеры
   - Пересоздаёт контейнеры через `docker compose up -d --build`
   - Ждёт 30 секунд для инициализации
   - Настраивает Grafana (datasource + dashboard)
   - Проверяет health endpoint

6. **Верификация** — curl-запросы к app, Grafana, Prometheus

### 🔄 Полная последовательность

```
Developer pushes code
        │
        ▼
┌───────────────┐     FAIL     ┌──────────┐
│  1. ТЕСТЫ     │─────────────▶│  СТОП ❌  │
│  (pytest)     │              └──────────┘
└───────┬───────┘
        │ PASS ✅
        ▼
┌───────────────┐
│  2. BUILD     │
│  Docker image │
│  → Docker Hub │
└───────┬───────┘
        │
        ▼
┌───────────────────────────────────────────┐
│  3. DEPLOY via ANSIBLE                    │
│  ┌─────────────────────────────────────┐  │
│  │ ansible-playbook playbook.yml       │  │
│  │  ├── role: docker (install Docker)  │  │
│  │  ├── role: app (deploy app)         │  │
│  │  │    ├── git clone/pull            │  │
│  │  │    ├── docker compose down       │  │
│  │  │    ├── docker compose up -d      │  │
│  │  │    └── health check              │  │
│  │  └── post: Grafana config           │  │
│  └─────────────────────────────────────┘  │
└───────────────────────────────────────────┘
        │
        ▼
┌───────────────┐
│  4. VERIFY    │
│  curl checks  │
│  ✅ DONE!     │
└───────────────┘
```

---

## 3. Пайплайн infrastructure-recovery.yml — восстановление с Terraform

### 🎯 Назначение

**Полное пересоздание** инфраструктуры AWS с нуля. Используется ТОЛЬКО при катастрофе — когда EC2 инстанс потерян или недоступен.

### ⚠️ Важно

- Запускается **вручную** (кнопка "Run workflow" в GitHub Actions)
- **Уничтожает** все текущие ресурсы AWS и создаёт новые
- **Новый IP** — при каждом запуске выделяется НОВЫЙ Elastic IP
- После запуска нужно обновить `SERVER_HOST` в GitHub Secrets

### 📋 Пошаговый разбор

#### Шаг 1: Очистка (AWS CLI)

```
🧹 Clean orphaned AWS resources
├── Terminate running EC2 instances (по тегу Project=my-devops-project)
├── Delete Key Pair (my-devops-key)
├── Release ALL Elastic IPs (по тегу health-dashboard-eip)
└── Delete Security Group (health-dashboard-sg)
```

**Зачем:** Terraform не может создать ресурсы, если предыдущие "осиротели" (существуют в AWS, но не в terraform.tfstate).

#### Шаг 2: Terraform Init + Apply

```
🔧 Terraform Init
├── Скачивает провайдер AWS
└── Инициализирует backend

🚀 Terraform Apply
├── Создаёт Key Pair (SSH ключ)
├── Создаёт Security Group (порты 22,80,443,3000,5000,9090)
├── Создаёт EC2 Instance (Amazon Linux 2023, t2.micro)
│   └── user_data: установка Docker, Docker Compose
├── Создаёт Elastic IP
└── Привязывает EIP к EC2
```

#### Шаг 3: Деплой приложения (SSH)

```
🚀 Deploy Application
├── SSH на новый сервер (используя ключ из Terraform output)
├── Clone репозитория в /opt/health-dashboard
├── Создание .env файла
├── docker compose up -d --build
├── Ожидание 30 секунд
├── Настройка Grafana
└── Проверка статуса контейнеров
```

#### Шаг 4: Верификация

```
✅ Verify services
├── curl http://$SERVER_IP — Nginx
├── curl http://$SERVER_IP:3000/api/health — Grafana
└── curl http://$SERVER_IP:9090/-/healthy — Prometheus
```

### 🔄 Полная последовательность

```
Admin clicks "Run workflow"
        │
        ▼
┌──────────────────┐
│ 1. CLEANUP       │
│ AWS CLI          │
│ ├── Kill EC2     │
│ ├── Delete Keys  │
│ ├── Release EIPs │
│ └── Delete SGs   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 2. TERRAFORM     │
│ terraform apply  │
│ ├── Key Pair     │
│ ├── Sec. Group   │
│ ├── EC2 Instance │
│ └── Elastic IP   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 3. WAIT 90s      │
│ (instance boot)  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 4. DEPLOY (SSH)  │
│ ├── git clone    │
│ ├── docker up    │
│ ├── grafana cfg  │
│ └── health check │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 5. VERIFY        │
│ ├── App ✅       │
│ ├── Grafana ✅   │
│ └── Prometheus ✅│
└──────────────────┘
         │
         ▼
  Обновить SERVER_HOST
  в GitHub Secrets
  с новым IP!
```

---

## 4. Terraform: что делает и как работает

### 📁 Файлы

```
terraform/
├── main.tf          # Основной конфиг: EC2, SG, EIP, Key Pair
├── variables.tf     # Переменные: регион, тип инстанса, AMI
├── outputs.tf       # Выходные данные: IP, SSH команда, URLs
├── terraform.tfstate # Состояние инфраструктуры (НЕ ТРОГАТЬ!)
└── my-devops-key.pem # SSH ключ (генерируется Terraform)
```

### 🏗️ Что создаёт Terraform

```
┌───────────────────── AWS eu-central-1 ─────────────────────┐
│                                                             │
│  ┌─────────────────────────────────────┐                    │
│  │ Security Group: health-dashboard-sg │                    │
│  │  Inbound:                           │                    │
│  │  ├── 22/tcp  (SSH)                  │                    │
│  │  ├── 80/tcp  (HTTP/Nginx)           │                    │
│  │  ├── 443/tcp (HTTPS)                │                    │
│  │  ├── 3000/tcp (Grafana)             │                    │
│  │  ├── 5000/tcp (Flask)               │                    │
│  │  └── 9090/tcp (Prometheus)          │                    │
│  └──────────────┬──────────────────────┘                    │
│                 │                                            │
│  ┌──────────────▼──────────────────────┐                    │
│  │ EC2 Instance (t2.micro)             │                    │
│  │  OS: Amazon Linux 2023              │                    │
│  │  Key: my-devops-key                 │◀──── Key Pair      │
│  │  user_data:                         │                    │
│  │  ├── install Docker                 │                    │
│  │  ├── install Docker Compose         │                    │
│  │  └── start Docker service           │                    │
│  └──────────────┬──────────────────────┘                    │
│                 │                                            │
│  ┌──────────────▼──────────────────────┐                    │
│  │ Elastic IP: 18.156.160.162          │                    │
│  │  (привязан к EC2)                   │                    │
│  └─────────────────────────────────────┘                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 🔑 Ключевые концепции

| Концепция | Описание |
|-----------|----------|
| **State** | `terraform.tfstate` — JSON файл, где Terraform помнит что он создал |
| **Idempotent** | Повторный `apply` не создаст дубликаты (сравнивает со state) |
| **user_data** | Bash-скрипт, выполняемый при ПЕРВОМ запуске EC2 |
| **Elastic IP** | Статический IP, переживает перезагрузку EC2 |

---

## 5. Ansible: что делает и как работает

### 📁 Файлы

```
ansible/
├── inventory.ini              # Список серверов (динамически генерируется в CI/CD)
├── playbook.yml               # Главный плейбук: роли + post_tasks
└── roles/
    ├── docker/
    │   └── tasks/main.yml     # Установка Docker + Docker Compose
    └── app/
        └── tasks/main.yml     # Деплой приложения через Docker Compose
```

### 🎭 Роли

#### Role: docker

```
docker/tasks/main.yml
├── Install Docker + pip                    # yum install docker python3-pip
├── Start & enable Docker service           # systemctl start docker
├── Add ec2-user to docker group            # usermod -aG docker ec2-user
├── Check for Docker Compose                # Проверяет plugin и standalone
└── Install Docker Compose (if missing)     # Скачивает бинарник v2.24.0
```

#### Role: app

```
app/tasks/main.yml
├── Install git                             # yum install git
├── Create /opt/health-dashboard            # mkdir + chown
├── Clone/update repository                 # git clone / git pull
├── Generate .env from .env.example         # cp .env.example .env
├── Stop old containers                     # docker compose down
├── Pull pre-built images                   # docker compose pull --ignore-buildable
├── Build and start containers              # docker compose up -d --build
├── Wait 30 seconds                         # pause
├── Show container status                   # docker compose ps
└── Health check                            # curl http://localhost/health
```

#### Post-tasks (в playbook.yml)

```
post_tasks
├── Configure Grafana                       # datasource + dashboard import
└── Final health verification               # uri module → http://localhost/health
```

### 🔑 Ключевые концепции

| Концепция | Описание |
|-----------|----------|
| **Inventory** | Файл со списком серверов и способами подключения |
| **Playbook** | YAML файл с инструкциями "что делать на серверах" |
| **Role** | Переиспользуемый набор задач (docker, app) |
| **Idempotent** | Задачи безопасно запускать повторно |
| **become: yes** | Выполнять от имени root (sudo) |
| **ignore_errors** | Продолжать даже если шаг упал (для некритичных задач) |

---

## 6. Terraform + Ansible: как дополняют друг друга

### 🎯 Разделение обязанностей

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│  TERRAFORM (Infrastructure)          ANSIBLE (Configuration)     │
│  ═══════════════════════            ════════════════════════     │
│                                                                  │
│  "ЧТО создать"                     "КАК настроить"              │
│                                                                  │
│  ├── EC2 Instance                   ├── Docker установка         │
│  ├── Security Group                 ├── Git clone репозитория    │
│  ├── Key Pair                       ├── Docker Compose up        │
│  ├── Elastic IP                     ├── Grafana настройка        │
│  └── VPC/Subnet (default)          └── Health checks            │
│                                                                  │
│  Уровень: облако/провайдер         Уровень: ОС/приложение       │
│  Язык: HCL                         Язык: YAML                   │
│  State: terraform.tfstate           State: нет (stateless)       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 🔄 Как они работают вместе

```
                TERRAFORM                           ANSIBLE
                ═════════                           ═══════

     ┌──────────────────────┐
     │ terraform apply      │
     │ → Creates:           │
     │   • EC2 instance     │
     │   • Security Group   │
     │   • Elastic IP       │
     │   • SSH Key          │
     └──────────┬───────────┘
                │
                │ Outputs: IP, SSH key
                │
                ▼
     ┌──────────────────────┐
     │ Ansible gets:        │
     │ • IP → inventory     │───────▶ ansible-playbook
     │ • SSH key → auth     │         playbook.yml
     └──────────────────────┘              │
                                           ▼
                                  ┌──────────────────┐
                                  │ На сервере:      │
                                  │ • Docker ready   │
                                  │ • App deployed   │
                                  │ • Monitoring up  │
                                  │ • Health: ✅     │
                                  └──────────────────┘
```

### 📊 Сравнительная таблица

| Критерий | Terraform | Ansible |
|----------|-----------|---------|
| **Что делает** | Создаёт инфраструктуру | Настраивает серверы |
| **Уровень** | Облако (AWS, GCP, Azure) | ОС и приложения |
| **Язык** | HCL (.tf файлы) | YAML (.yml файлы) |
| **State** | Хранит в terraform.tfstate | Stateless (без состояния) |
| **Подход** | Декларативный ("хочу EC2") | Процедурный + декларативный |
| **Идемпотентность** | Да (через state) | Да (через модули) |
| **Подключение** | API облака | SSH к серверам |
| **В проекте** | infrastructure-recovery.yml | ci-cd.yml |
| **Когда** | Катастрофа / новый сервер | Каждый деплой |

---

## 7. Когда использовать какой инструмент

### ✅ Используй Terraform когда:

- Нужно **создать** сервер (EC2, VPS)
- Нужно **настроить сеть** (Security Groups, VPC)
- Нужно **создать базу данных** (RDS, ElastiCache)
- Нужно **управлять DNS** (Route53)
- Сервер **потерян** и нужно пересоздать
- Нужно воспроизвести инфраструктуру в другом регионе

### ✅ Используй Ansible когда:

- Нужно **деплоить код** на существующий сервер
- Нужно **установить ПО** (Docker, Nginx, Node.js)
- Нужно **настроить сервисы** (Grafana, Prometheus)
- Нужно **обновить конфигурацию** (nginx.conf, .env)
- Нужно делать это **при каждом коммите** (CI/CD)
- Нужно работать с **несколькими серверами** одинаково

### 🔄 В нашем проекте:

```
Сценарий: "Обновил код, нужен деплой"
→ Инструмент: ANSIBLE (ci-cd.yml)
→ Push в main → тесты → Docker build → Ansible deploy

Сценарий: "Сервер умер, всё пропало"
→ Инструмент: TERRAFORM (infrastructure-recovery.yml)
→ Нажать кнопку → cleanup → terraform apply → deploy

Сценарий: "Нужно добавить порт в firewall"
→ Инструмент: TERRAFORM (Security Group в main.tf)
→ terraform apply

Сценарий: "Нужно обновить Grafana dashboard"
→ Инструмент: ANSIBLE (через CI/CD при push)
→ Commit → push → автоматический деплой
```

---

## 8. Секреты GitHub Actions

### Для ci-cd.yml (Ansible деплой)

| Секрет | Описание | Пример |
|--------|----------|--------|
| `SERVER_HOST` | IP сервера | `18.156.160.162` |
| `SERVER_USER` | SSH пользователь | `ec2-user` |
| `SSH_PRIVATE_KEY` | Приватный SSH ключ | Содержимое `.pem` файла |
| `DOCKER_USERNAME` | Docker Hub логин | `zaburdaev` |
| `DOCKER_PASSWORD` | Docker Hub пароль/токен | `dckr_pat_...` |

### Для infrastructure-recovery.yml (Terraform)

| Секрет | Описание | Пример |
|--------|----------|--------|
| `AWS_ACCESS_KEY_ID` | AWS ключ доступа | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS секретный ключ | `wJal...` |

### ⚠️ После infrastructure-recovery.yml

Новый IP будет выведен в логах. Нужно **вручную** обновить `SERVER_HOST` в GitHub Secrets.

---

## 9. Диаграммы и схемы

### Общая архитектура проекта

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         GITHUB REPOSITORY                               │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌──────────────────────┐   │
│  │ app/     │  │ ansible/ │  │ terraform/│  │ .github/workflows/   │   │
│  │ Flask    │  │ playbook │  │ main.tf   │  │ ├── ci-cd.yml        │   │
│  │ Python   │  │ roles/   │  │ vars.tf   │  │ └── infra-recovery   │   │
│  └────┬─────┘  └────┬─────┘  └─────┬─────┘  └──────────┬───────────┘   │
│       │              │              │                    │               │
└───────┼──────────────┼──────────────┼────────────────────┼───────────────┘
        │              │              │                    │
        ▼              ▼              ▼                    ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         GITHUB ACTIONS                                   │
│                                                                          │
│  ci-cd.yml ──────────────────────┐   infra-recovery.yml ──────────┐     │
│  │ 1. pytest (тесты)           │   │ 1. AWS CLI cleanup          │     │
│  │ 2. Docker build + push      │   │ 2. terraform init           │     │
│  │ 3. Ansible playbook ────────┼─┐ │ 3. terraform apply          │     │
│  └─────────────────────────────┘ │ │ 4. SSH deploy               │     │
│                                  │ └──────────────────────────────┘     │
│                                  │                                       │
└──────────────────────────────────┼───────────────────────────────────────┘
                                   │
                          SSH + Ansible
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                    AWS EC2: 18.156.160.162                                │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐    │
│  │                    DOCKER COMPOSE                                │    │
│  │  ┌──────────┐ ┌────────┐ ┌──────────┐ ┌───────┐ ┌────────────┐ │    │
│  │  │  Flask   │ │ Nginx  │ │ Grafana  │ │Promet.│ │ PostgreSQL │ │    │
│  │  │  :5000   │ │  :80   │ │  :3000   │ │ :9090 │ │  :5432     │ │    │
│  │  └──────────┘ └────────┘ └──────────┘ └───────┘ └────────────┘ │    │
│  │  ┌──────────┐                                                    │    │
│  │  │  Redis   │                                                    │    │
│  │  │  :6379   │                                                    │    │
│  │  └──────────┘                                                    │    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### Жизненный цикл деплоя

```
    РАЗРАБОТЧИК                      GITHUB                        СЕРВЕР
    ───────────                      ──────                        ──────

  git push main
        │
        ├─────────────────▶ CI/CD Pipeline запускается
        │                        │
        │                   1. pytest ✅
        │                        │
        │                   2. Docker build
        │                   Docker Hub push ✅
        │                        │
        │                   3. pip install ansible
        │                   Генерация inventory
        │                        │
        │                   4. ansible-playbook ─────────────▶ SSH connect
        │                                                      │
        │                                                 git pull
        │                                                 docker compose down
        │                                                 docker compose up ✅
        │                                                 health check ✅
        │                        │◀──────────────────────── OK
        │                        │
        │                   5. curl verify ✅
        │                        │
        │◀───────────────── ✅ Pipeline GREEN
        │
   Готово! 🎉
```

---

## 📝 Заключение

| Что | Где | Как |
|-----|-----|-----|
| **Код приложения** | `app/` | Flask + Python |
| **Контейнеризация** | `docker-compose.yml` | 6 сервисов |
| **Инфраструктура** | `terraform/` | EC2 + SG + EIP |
| **Конфигурация** | `ansible/` | Docker + App deploy |
| **CI/CD деплой** | `ci-cd.yml` | Tests → Build → **Ansible** |
| **Восстановление** | `infrastructure-recovery.yml` | Cleanup → **Terraform** → Deploy |
| **Мониторинг** | Grafana + Prometheus | Метрики в реальном времени |

**Terraform** создаёт сервер. **Ansible** настраивает его и деплоит приложение. **GitHub Actions** автоматизирует всё это.
