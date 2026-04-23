# 🔧 Руководство по устранению неполадок

> **Автор:** Vitalii Zaburdaiev | DevOpsUA6  
> **Проект:** Health Dashboard (my-devops-project)

---

## 📋 Содержание

1. [Ошибки CI/CD Pipeline](#1--ошибки-cicd-pipeline)
2. [Ошибки Docker](#2--ошибки-docker)
3. [Ошибки при деплое на сервер](#3--ошибки-при-деплое-на-сервер)
4. [Ошибки Terraform](#4--ошибки-terraform)
5. [Как задеплоить вручную](#5--как-задеплоить-вручную)
6. [Как отладить деплой](#6--как-отладить-деплой)

---

## 1. 🔄 Ошибки CI/CD Pipeline

### ❌ Ошибка: "git: command not found"

**Описание:** На сервере не установлен Git, и CI/CD не может клонировать репозиторий.

**Лог ошибки:**
```
📦 First deployment — cloning repository...
sudo: git: command not found
```

**Причина:** Git не был включён в user_data скрипт Terraform при создании EC2 инстанса.

**Решение:**
```bash
# Подключитесь к серверу
ssh -i my-devops-key.pem ec2-user@3.127.155.114

# Установите git
sudo dnf install -y git    # Amazon Linux 2023
# или
sudo yum install -y git    # Amazon Linux 2

# Проверьте установку
git --version
```

**Профилактика:** В Terraform `user_data` и Ansible playbook уже добавлена установка git.

---

### ❌ Ошибка: "cp: cannot stat '.env.example': No such file or directory"

**Описание:** Файл `.env.example` не найден, потому что репозиторий не был клонирован (из-за отсутствия git).

**Решение:** Установите git и клонируйте репозиторий (см. ошибку выше), затем:
```bash
cd /opt/health-dashboard
cp .env.example .env
```

---

### ❌ Ошибка: "no configuration file provided: not found" / "Failed to pull images"

**Описание:** Docker Compose не находит `docker-compose.yml`, потому что репозиторий не был клонирован.

**Решение:** Клонируйте репозиторий и запустите сервисы:
```bash
cd /opt
sudo git clone https://github.com/zaburdaev/my-devops-project.git /opt/health-dashboard
sudo chown -R ec2-user:ec2-user /opt/health-dashboard
cd /opt/health-dashboard
cp .env.example .env
docker compose up -d --build
```

---

### ❌ Ошибка: "compose build requires buildx 0.17.0 or later"

**Описание:** Docker Buildx не установлен или устаревшая версия.

**Решение:**
```bash
# Установите Docker Buildx
sudo mkdir -p /usr/local/lib/docker/cli-plugins/
sudo curl -SL "https://github.com/docker/buildx/releases/download/v0.21.1/buildx-v0.21.1.linux-amd64" -o /usr/local/lib/docker/cli-plugins/docker-buildx
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

# Проверьте
docker buildx version
```

---

### ❌ Ошибка: "docker: 'compose' is not a docker command"

**Описание:** Docker Compose не установлен как плагин Docker CLI.

**Решение:**
```bash
# Установите Docker Compose как плагин
sudo mkdir -p /usr/local/lib/docker/cli-plugins/
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Также установите standalone версию
sudo cp /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Проверьте
docker compose version
docker-compose --version
```

---

### ❌ Ошибка: "Directory not found" (cd: /opt/health-dashboard: No such file or directory)

**Описание:** GitHub Actions при деплое пытается перейти в директорию `/opt/health-dashboard`, но она ещё не создана на сервере.

**Лог ошибки:**
```
bash: line 2: cd: /opt/health-dashboard: No such file or directory
2026/04/12 21:21:57 Process exited with status 1
🚀 Starting deployment...
❌ Directory not found
Error: Process completed with exit code 1.
```

**Причина:** Это первый деплой на сервер — директория ещё не была создана. Предыдущая версия скрипта предполагала, что директория уже существует.

**Решение:** Эта проблема исправлена в обновлённом workflow. Скрипт деплоя теперь автоматически:
1. Создаёт директорию `sudo mkdir -p /opt/health-dashboard`
2. При первом деплое — клонирует репозиторий
3. При последующих — делает `git pull`

**Если проблема повторяется**, выполните вручную:
```bash
ssh -i my-devops-key.pem ec2-user@3.127.155.114
sudo mkdir -p /opt/health-dashboard
cd /opt
sudo git clone https://github.com/zaburdaev/my-devops-project.git health-dashboard
sudo chown -R ec2-user:ec2-user /opt/health-dashboard
cd /opt/health-dashboard
cp .env.example .env
docker-compose up -d
```

**Альтернативное решение:** Запустите Ansible playbook для подготовки сервера:
```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

---

### ❌ Ошибка: Тесты не проходят в CI, но проходят локально

**Причина:**
- Разные версии Python (локально vs CI)
- Зависимости не указаны в `requirements.txt`
- Тесты зависят от локального окружения

**Решение:**
```bash
# Используйте ту же версию Python, что и в CI
python3.11 -m pytest tests/ -v

# Проверьте, что все зависимости указаны
pip freeze | grep -i <package-name>
```

---

### ❌ Ошибка: Build — "unauthorized" (Docker Hub)

**Причина:** Неверные или истёкшие учётные данные Docker Hub.

**Решение:**
1. Перейдите в [Docker Hub Security Settings](https://hub.docker.com/settings/security)
2. Создайте новый access token
3. Обновите секрет `DOCKER_HUB_TOKEN` в GitHub → Settings → Secrets

---

### ❌ Ошибка: Deploy — "Connection refused"

**Причина:** Сервер недоступен или SSH неправильно настроен.

**Решение:**
1. Проверьте, что сервер запущен (AWS Console или `terraform output`)
2. Убедитесь, что `SERVER_HOST` содержит правильный IP
3. Проверьте `SSH_PRIVATE_KEY` — должен содержать полный ключ (включая `-----BEGIN` и `-----END`)
4. Убедитесь, что порт 22 открыт в Security Group

---

### ❌ Ошибка: Deploy пропускается (Deployment skipped)

**Причина:** Секреты для деплоя не настроены в GitHub.

**Решение:** Добавьте секреты в GitHub → Settings → Secrets and variables → Actions:
- `SERVER_HOST` — IP адрес сервера (например, `3.127.155.114`)
- `SERVER_USER` — SSH пользователь (`ec2-user`)
- `SSH_PRIVATE_KEY` — приватный SSH ключ

---

## 2. 🐳 Ошибки Docker

### ❌ Ошибка: "Cannot connect to the Docker daemon"

**Решение:**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### ❌ Ошибка: "Port already in use"

**Решение:**
```bash
# Посмотреть, что использует порт
sudo lsof -i :5000
# Или остановить все контейнеры
docker-compose down
```

### ❌ Ошибка: "No space left on device"

**Решение:**
```bash
# Очистить неиспользуемые образы и контейнеры
docker system prune -a
docker volume prune
```

---

## 3. 🚀 Ошибки при деплое на сервер

### ❌ Ошибка: "Permission denied" при SSH подключении

**Решение:**
```bash
# Установите правильные права на ключ
chmod 400 my-devops-key.pem

# Подключитесь
ssh -i my-devops-key.pem ec2-user@<SERVER_IP>
```

### ❌ Ошибка: docker-compose не найден на сервере

**Решение:**
```bash
# Установите Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### ❌ Приложение не отвечает после деплоя

**Решение:**
```bash
cd /opt/health-dashboard
docker-compose ps          # Проверьте статус контейнеров
docker-compose logs app    # Посмотрите логи приложения
docker-compose logs nginx  # Посмотрите логи Nginx
```

---

## 4. 🏗️ Ошибки Terraform

### ❌ Ошибка: "Error creating EC2 instance"

**Решение:**
- Проверьте AWS credentials: `aws sts get-caller-identity`
- Убедитесь, что выбран правильный регион в `variables.tf`
- Проверьте лимиты EC2 в вашем AWS аккаунте

### ❌ Ошибка: "Key pair already exists"

**Решение:**
```bash
cd terraform
terraform destroy -auto-approve
terraform apply -auto-approve
```

---

## 5. 🛠️ Как задеплоить вручную

Если CI/CD не работает, можно задеплоить вручную:

### Шаг 1: Подключитесь к серверу
```bash
ssh -i my-devops-key.pem ec2-user@3.127.155.114
```

### Шаг 2: Подготовьте директорию
```bash
sudo mkdir -p /opt/health-dashboard
cd /opt
sudo git clone https://github.com/zaburdaev/my-devops-project.git health-dashboard
sudo chown -R ec2-user:ec2-user /opt/health-dashboard
cd /opt/health-dashboard
```

### Шаг 3: Настройте окружение
```bash
cp .env.example .env
# Отредактируйте .env при необходимости
nano .env
```

### Шаг 4: Запустите приложение
```bash
docker-compose pull
docker-compose up -d
docker-compose ps
```

### Шаг 5: Проверьте
```bash
curl http://localhost:5000/health
curl http://localhost/
```

---

## 6. 🔍 Как отладить деплой

### Просмотр логов GitHub Actions
1. Перейдите в репозиторий → **Actions**
2. Нажмите на нужный workflow run
3. Нажмите на job **"🚀 Deploy to Server"**
4. Раскройте step **"Deploy via SSH"** для просмотра вывода

### Просмотр логов на сервере
```bash
ssh -i my-devops-key.pem ec2-user@3.127.155.114

# Логи Docker контейнеров
cd /opt/health-dashboard
docker-compose logs -f

# Логи конкретного сервиса
docker-compose logs -f app
docker-compose logs -f nginx

# Системные логи
sudo journalctl -u docker -f
```

### Полезные команды для диагностики
```bash
# Статус контейнеров
docker-compose ps

# Использование ресурсов
docker stats

# Свободное место на диске
df -h

# Использование памяти
free -h

# Проверка сети
curl -v http://localhost:5000/health
```

---

## 📖 Связанная документация

- 🔄 [CI/CD](./CI_CD.md) — Настройка CI/CD pipeline
- 🚀 [Деплой на AWS](./AWS_DEPLOYMENT_RU.md) — Развёртывание на AWS
- 📊 [Мониторинг](./MONITORING.md) — Настройка мониторинга
- 🏗️ [Архитектура](./ARCHITECTURE.md) — Архитектура проекта

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>



---

## 7. 🆘 Сервер удалён — как восстановить деплой

### Симптомы

- GitHub Actions падает на шаге Deploy по SSH
- Ошибка: `dial tcp <old_ip>:22: i/o timeout`
- В Terraform state есть инстанс, но в AWS он уже удалён/terminated

### Пошаговое восстановление

```bash
# 1) Пересоздать инфраструктуру
cd /home/ubuntu/my-devops-project/terraform
terraform destroy -auto-approve || true
terraform init
terraform apply -auto-approve

# 2) Получить новый IP и ключ
terraform output -raw instance_public_ip
terraform output -raw ssh_private_key > my-devops-key.pem
chmod 600 my-devops-key.pem

# 3) Первичный деплой приложения
cd /home/ubuntu/my-devops-project/ansible
ansible-playbook -i inventory.ini playbook.yml
```

### Что обязательно обновить в GitHub Secrets

- `SERVER_HOST` → новый IP
- `SERVER_USER` → `ec2-user`
- `SSH_PRIVATE_KEY` → новый приватный ключ

После обновления секретов сделайте push в `main`, чтобы заново проверить CI/CD деплой.
