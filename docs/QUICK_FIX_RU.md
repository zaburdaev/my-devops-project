# 🚑 Быстрое исправление — Ручной деплой

> **Автор:** Vitalii Zaburdaiev | DevOpsUA6  
> **Проект:** Health Dashboard (my-devops-project)  
> **Сервер:** 18.197.7.122

---

Если CI/CD pipeline не работает, используйте эту инструкцию для быстрого ручного деплоя.

---

## 📋 Пошаговая инструкция

### Шаг 1: Подключитесь к серверу

```bash
ssh -i my-devops-key.pem ec2-user@18.197.7.122
```

> ⚠️ Если получаете ошибку "Permission denied", выполните: `chmod 400 my-devops-key.pem`

---

### Шаг 2: Установите Git (если не установлен)

```bash
# Проверьте наличие git
git --version

# Если не установлен:
sudo dnf install -y git
```

---

### Шаг 3: Установите Docker Buildx и Compose (если нужно)

```bash
# Docker Buildx
sudo mkdir -p /usr/local/lib/docker/cli-plugins/
sudo curl -SL "https://github.com/docker/buildx/releases/download/v0.21.1/buildx-v0.21.1.linux-amd64" \
  -o /usr/local/lib/docker/cli-plugins/docker-buildx
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

# Docker Compose (как плагин)
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Docker Compose (standalone)
sudo cp /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

---

### Шаг 4: Клонируйте репозиторий

```bash
# Удалите старую директорию (если есть)
sudo rm -rf /opt/health-dashboard

# Клонируйте
sudo git clone https://github.com/zaburdaev/my-devops-project.git /opt/health-dashboard
sudo chown -R ec2-user:ec2-user /opt/health-dashboard
```

---

### Шаг 5: Настройте окружение

```bash
cd /opt/health-dashboard
cp .env.example .env
```

---

### Шаг 6: Запустите приложение

```bash
cd /opt/health-dashboard
docker compose up -d --build
```

> ⏱️ Первый запуск может занять 2-5 минут (загрузка образов и сборка).

---

### Шаг 7: Проверьте, что всё работает

```bash
# Статус контейнеров
docker compose ps

# Проверка здоровья приложения
curl http://localhost:5000/health

# Проверка через Nginx
curl http://localhost/health

# Проверка Grafana
curl -s http://localhost:3000 | head -1
```

---

## ✅ Ожидаемый результат

После успешного деплоя должны работать:

| Сервис | URL (внутри сервера) | URL (снаружи) | Описание |
|--------|---------------------|---------------|----------|
| Приложение | http://localhost:5000 | http://18.197.7.122:5000 | Flask API |
| Nginx | http://localhost:80 | http://18.197.7.122 | Реверс-прокси |
| Grafana | http://localhost:3000 | http://18.197.7.122:3000 | Мониторинг |
| Prometheus | http://localhost:9090 | http://18.197.7.122:9090 | Метрики |

---

## 🔍 Если что-то не работает

```bash
# Посмотрите логи
docker compose logs

# Логи конкретного сервиса
docker compose logs app
docker compose logs nginx

# Перезапустите всё
docker compose down
docker compose up -d --build
```

Подробнее: [TROUBLESHOOTING_RU.md](./TROUBLESHOOTING_RU.md)

---

## 📝 Одна команда для всего

Скопируйте и вставьте для полного деплоя:

```bash
sudo dnf install -y git && \
sudo mkdir -p /usr/local/lib/docker/cli-plugins/ && \
sudo curl -SL "https://github.com/docker/buildx/releases/download/v0.21.1/buildx-v0.21.1.linux-amd64" -o /usr/local/lib/docker/cli-plugins/docker-buildx && \
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx && \
sudo rm -rf /opt/health-dashboard && \
sudo git clone https://github.com/zaburdaev/my-devops-project.git /opt/health-dashboard && \
sudo chown -R ec2-user:ec2-user /opt/health-dashboard && \
cd /opt/health-dashboard && \
cp .env.example .env && \
docker compose up -d --build && \
sleep 15 && \
docker compose ps && \
curl http://localhost:5000/health
```

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>
