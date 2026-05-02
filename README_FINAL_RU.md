# 🚀 Health Dashboard — DevOps Project

## Полное руководство по инфраструктуре с постоянным IP

**Автор:** Vitalii Zaburdaiev | DevOpsUA6  
**IP-адрес (постоянный):** `18.197.7.122`  
**Регион AWS:** eu-central-1 (Франкфурт)  
**Статус:** ✅ Всё работает, IP защищён от изменений

---

## 📖 Содержание

1. [Quick Start — быстрый доступ](#-quick-start)
2. [Текущая инфраструктура](#-текущая-инфраструктура)
3. [CI/CD Pipeline — автодеплой](#-cicd-pipeline)
4. [Recovery Pipeline — восстановление](#-recovery-pipeline)
5. [Как защищён постоянный IP](#-как-защищён-постоянный-ip)
6. [Ссылки на всю документацию](#-документация)
7. [Troubleshooting — решение проблем](#-troubleshooting)

---

## ⚡ Quick Start

### Доступ к сервисам (прямо сейчас)

| Сервис | URL | Описание |
|--------|-----|----------|
| 🌐 **Приложение** | http://18.197.7.122 | Health Dashboard (Flask) |
| 💚 **Health Check** | http://18.197.7.122/health | JSON-статус приложения |
| 📊 **Grafana** | http://18.197.7.122:3000 | Дашборды мониторинга |
| 🔥 **Prometheus** | http://18.197.7.122:9090 | Метрики и алерты |

### SSH-доступ к серверу

```bash
ssh -i terraform/my-devops-key.pem ec2-user@18.197.7.122
```

### Деплой нового кода

```bash
git add . && git commit -m "feat: новая фича"
git push origin main
# → CI/CD pipeline запустится автоматически
```

### Восстановление после аварии

```
GitHub → Actions → Infrastructure Recovery → Run workflow
# → Сервер пересоздастся, IP останется 18.197.7.122
```

---

## 🏗 Текущая инфраструктура

### Сервер

| Параметр | Значение |
|----------|----------|
| **IP-адрес** | `18.197.7.122` (Elastic IP, постоянный) |
| **Инстанс** | EC2 `t2.micro` (Free Tier) |
| **ОС** | Amazon Linux 2023 |
| **Регион** | eu-central-1 (Франкфурт) |
| **SSH-ключ** | `my-devops-key` |

### Сервисы (Docker Compose)

| Контейнер | Порт | Назначение |
|-----------|------|------------|
| **health-dashboard** | 80 (→5000) | Flask-приложение через Nginx |
| **nginx** | 80 | Reverse proxy |
| **prometheus** | 9090 | Сбор метрик |
| **grafana** | 3000 | Визуализация метрик |
| **loki** | 3100 | Агрегация логов |
| **node-exporter** | 9100 | Метрики сервера |

### Безопасность (Security Group)

Открытые порты: `22` (SSH), `80` (HTTP), `443` (HTTPS), `3000` (Grafana), `9090` (Prometheus), `9100` (Node Exporter), `3100` (Loki)

---

## 🔄 CI/CD Pipeline

**Файл:** `.github/workflows/ci-cd.yml`  
**Триггер:** push в `main` или pull request

### Этапы

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  1. TEST    │───▶│  2. BUILD   │───▶│  3. DEPLOY  │───▶│  4. VERIFY  │
│  pytest     │    │  Docker     │    │  Ansible    │    │  curl /health│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

| Этап | Что делает |
|------|-----------|
| **🧪 Test** | Запускает `pytest` с проверкой покрытия |
| **🐳 Build** | Собирает Docker-образ, пушит в Docker Hub |
| **🚀 Deploy** | Ansible подключается по SSH, обновляет контейнеры |
| **✅ Verify** | Проверяет `/health` endpoint, что приложение работает |

### Необходимые GitHub Secrets

| Secret | Описание |
|--------|----------|
| `DOCKER_USERNAME` | Логин Docker Hub |
| `DOCKER_PASSWORD` | Пароль Docker Hub |
| `SSH_PRIVATE_KEY` | Приватный SSH-ключ для EC2 |
| `SERVER_IP` | `18.197.7.122` |

---

## 🔧 Recovery Pipeline

**Файл:** `.github/workflows/infrastructure-recovery.yml`  
**Триггер:** ручной запуск (workflow_dispatch)  
**Ключевое:** IP-адрес **НЕ меняется** при восстановлении!

### Как работает восстановление

```
Авария                     Recovery Pipeline                    Результат
═══════                    ═════════════════                    ═════════

EC2 умер          ┌─────────────────────────┐
или удалён ──────▶│ 1. Cleanup              │          IP: 18.197.7.122
                  │    Удаляет ТОЛЬКО:       │          ══════════════════
                  │    - EC2 instance        │          НЕ МЕНЯЕТСЯ!
                  │    - Key Pair            │
                  │    - Security Group      │
                  │    НЕ удаляет: EIP ✋    │
                  └─────────┬───────────────┘
                            ▼
                  ┌─────────────────────────┐
                  │ 2. Terraform Import     │
                  │    Импортирует EIP       │
                  │    обратно в state       │
                  └─────────┬───────────────┘
                            ▼
                  ┌─────────────────────────┐
                  │ 3. Terraform Apply      │
                  │    Создаёт новый EC2     │
                  │    Привязывает EIP к нему│
                  └─────────┬───────────────┘
                            ▼
                  ┌─────────────────────────┐
                  │ 4. Ansible              │
                  │    Docker + сервисы      │
                  │    Мониторинг            │
                  └─────────┬───────────────┘
                            ▼
                  ┌─────────────────────────┐
                  │ 5. Verify               │
                  │    curl /health          │
                  │    ✅ Всё работает       │
                  └─────────────────────────┘
```

### Необходимые GitHub Secrets (дополнительно)

| Secret | Описание |
|--------|----------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key |

---

## 🛡 Как защищён постоянный IP

### Проблема (раньше)

При каждом Recovery IP менялся, потому что `terraform destroy` удалял **все** ресурсы включая Elastic IP.

### Решение (сейчас) — 3 уровня защиты

#### 1️⃣ Terraform lifecycle — prevent_destroy

```hcl
resource "aws_eip" "app_eip" {
  domain = "vpc"

  lifecycle {
    prevent_destroy = true        # Запрещает удаление EIP
    ignore_changes = [
      instance,                   # Не пересоздавать при смене инстанса
      network_interface,
      associate_with_private_ip
    ]
  }
}
```

**Эффект:** `terraform destroy` откажется удалять EIP и выдаст ошибку.

#### 2️⃣ Recovery Pipeline — selective cleanup

Recovery pipeline удаляет только:
- ❌ EC2 instance (будет создан новый)
- ❌ Key Pair (будет создан новый)
- ❌ Security Group (будет создан новый)

Recovery pipeline **НЕ удаляет:**
- ✅ **Elastic IP** — остаётся в AWS

#### 3️⃣ Terraform import — автоматическая привязка

После cleanup pipeline автоматически:
1. Находит существующий EIP по тегу `health-dashboard-eip`
2. Импортирует его в новый Terraform state
3. Привязывает к новому EC2 инстансу

**Результат:** IP `18.197.7.122` остаётся постоянным при любом количестве Recovery.

---

## 📚 Документация

### Основные документы

| Документ | Описание |
|----------|----------|
| [SOLUTION_SUMMARY_RU.md](SOLUTION_SUMMARY_RU.md) | Итоговое описание решения с постоянным IP |
| [COMPLETE_GUIDE_FOR_NON_IT_RU.md](COMPLETE_GUIDE_FOR_NON_IT_RU.md) | Полное руководство для неспециалистов |
| [FINAL_INSTRUCTIONS_RU.md](FINAL_INSTRUCTIONS_RU.md) | Финальные инструкции |
| [README.md](README.md) | Основной README (EN) |

### Инфраструктура и DevOps

| Документ | Описание |
|----------|----------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Архитектура проекта |
| [docs/CI_CD.md](docs/CI_CD.md) | Описание CI/CD pipeline |
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) | Инструкция по деплою |
| [docs/INFRASTRUCTURE_RECOVERY_RU.md](docs/INFRASTRUCTURE_RECOVERY_RU.md) | Восстановление инфраструктуры |

### Elastic IP и Recovery

| Документ | Описание |
|----------|----------|
| [docs/PERSISTENT_IP_GUIDE_RU.md](docs/PERSISTENT_IP_GUIDE_RU.md) | Руководство по Elastic IP |
| [docs/PERSISTENT_IP_SUMMARY_RU.md](docs/PERSISTENT_IP_SUMMARY_RU.md) | Краткое описание решения |
| [docs/PERSISTENT_IP_TEST_SCENARIOS_RU.md](docs/PERSISTENT_IP_TEST_SCENARIOS_RU.md) | Сценарии тестирования |
| [docs/RECOVERY_FLOW_DIAGRAM_RU.md](docs/RECOVERY_FLOW_DIAGRAM_RU.md) | Диаграмма потока Recovery |
| [docs/DISASTER_RECOVERY_RU.md](docs/DISASTER_RECOVERY_RU.md) | Disaster Recovery план |

### Мониторинг

| Документ | Описание |
|----------|----------|
| [docs/MONITORING.md](docs/MONITORING.md) | Настройка мониторинга |
| [docs/MONITORING_SIMPLE_RU.md](docs/MONITORING_SIMPLE_RU.md) | Мониторинг (простое описание) |
| [docs/MONITORING_COMPARISON.md](docs/MONITORING_COMPARISON.md) | Сравнение инструментов мониторинга |

### Безопасность и тестирование

| Документ | Описание |
|----------|----------|
| [docs/SECURITY_BEST_PRACTICES.md](docs/SECURITY_BEST_PRACTICES.md) | Лучшие практики безопасности |
| [docs/TESTING.md](docs/TESTING.md) | Тестирование |
| [docs/TROUBLESHOOTING_RU.md](docs/TROUBLESHOOTING_RU.md) | Решение проблем |

### Презентации

| Документ | Описание |
|----------|----------|
| [PRESENTATION_SCRIPT.md](PRESENTATION_SCRIPT.md) | Скрипт презентации (EN) |
| [PRESENTATION_SCRIPT_RU.md](docs/DEMO_SCRIPT_RU.md) | Скрипт презентации (RU) |
| [docs/DEMO_SCRIPT_MONITORING_RU.md](docs/DEMO_SCRIPT_MONITORING_RU.md) | Демо мониторинга (RU) |
| [PIPELINES_TERRAFORM_ANSIBLE_GUIDE_RU.md](PIPELINES_TERRAFORM_ANSIBLE_GUIDE_RU.md) | Pipelines + Terraform + Ansible |

---

## 🔧 Troubleshooting

### Приложение недоступно (http://18.197.7.122 не открывается)

```bash
# 1. Проверить, что EC2 работает
ssh -i terraform/my-devops-key.pem ec2-user@18.197.7.122

# 2. Проверить Docker-контейнеры
sudo docker ps

# 3. Если контейнеры не запущены
cd /home/ec2-user/app
sudo docker compose up -d

# 4. Если сервер не доступен вообще — запустить Recovery
# GitHub → Actions → Infrastructure Recovery → Run workflow
```

### SSH не работает

```bash
# Проверить права на ключ
chmod 600 terraform/my-devops-key.pem

# Попробовать подключиться с отладкой
ssh -vvv -i terraform/my-devops-key.pem ec2-user@18.197.7.122
```

### Grafana не открывается

```bash
# На сервере:
sudo docker ps | grep grafana
sudo docker logs grafana

# Перезапустить Grafana
sudo docker compose restart grafana
```

### CI/CD pipeline падает

| Ошибка | Решение |
|--------|---------|
| Docker push failed | Проверить `DOCKER_USERNAME` и `DOCKER_PASSWORD` в GitHub Secrets |
| SSH connection refused | Проверить `SSH_PRIVATE_KEY` и `SERVER_IP` в GitHub Secrets |
| Tests failed | Посмотреть вывод pytest, исправить код |
| Deploy failed | Проверить что сервер доступен по SSH |

### Recovery pipeline падает

| Ошибка | Решение |
|--------|---------|
| AWS credentials error | Проверить `AWS_ACCESS_KEY_ID` и `AWS_SECRET_ACCESS_KEY` |
| Terraform apply failed | Проверить лимиты AWS (max EC2 instances) |
| EIP not found | Проверить что EIP `18.197.7.122` существует в AWS Console |
| Ansible failed | Подождать 2-3 минуты после создания EC2, перезапустить workflow |

### IP изменился (теоретически невозможно, но если всё же)

```bash
# 1. Проверить текущий EIP в AWS
aws ec2 describe-addresses --filters "Name=tag:Name,Values=health-dashboard-eip"

# 2. Обновить GitHub Secret SERVER_IP

# 3. Обновить ansible/inventory.ini

# 4. Обновить документацию
```

### Как проверить что всё работает

```bash
# Быстрая проверка всех сервисов
curl -s http://18.197.7.122/health | python3 -m json.tool
curl -s -o /dev/null -w "%{http_code}" http://18.197.7.122:3000/
curl -s -o /dev/null -w "%{http_code}" http://18.197.7.122:9090/
```

---

## 📊 Технологический стек

| Категория | Технология |
|-----------|-----------|
| **Приложение** | Python 3.11, Flask, Gunicorn |
| **Контейнеризация** | Docker, Docker Compose |
| **IaC** | Terraform (AWS provider) |
| **Конфигурация** | Ansible |
| **CI/CD** | GitHub Actions |
| **Мониторинг** | Prometheus + Grafana + Loki |
| **Облако** | AWS (EC2, EIP, Security Groups) |
| **Reverse Proxy** | Nginx |

---

*Последнее обновление: Май 2026*  
*Постоянный IP: 18.197.7.122 — защищён prevent_destroy*
