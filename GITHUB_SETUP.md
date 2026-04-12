# GitHub Repository Setup — my-devops-project

## 🔗 Repository URL

**GitHub:** [https://github.com/zaburdaev/my-devops-project](https://github.com/zaburdaev/my-devops-project)

---

## ✅ CI/CD Pipeline Status

| Job | Status | Описание |
|-----|--------|----------|
| **Run Tests** | ✅ Passed | Unit-тесты (pytest) и линтинг (flake8) |
| **Build & Push Docker Image** | ✅ Passed | Сборка Docker-образа и push в Docker Hub |
| **Deploy to Server** | ⚠️ Skipped/Failed | Требует настройки сервера (SERVER_HOST, SSH_PRIVATE_KEY) |

> **Примечание:** Deploy-шаг ожидаемо не проходит, так как для него нужен настроенный EC2-сервер (через Terraform/Ansible). Тесты и сборка Docker-образа работают корректно.

---

## 🔑 Настроенные GitHub Secrets

Следующие secrets добавлены в репозиторий:

| Secret | Назначение |
|--------|-----------|
| `DOCKER_HUB_TOKEN` | Пароль/токен для Docker Hub (push образов) |
| `AWS_ACCESS_KEY_ID` | AWS Access Key для Terraform |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key для Terraform |

### Secrets, которые нужно добавить для полного деплоя:

| Secret | Назначение |
|--------|-----------|
| `SERVER_HOST` | IP-адрес EC2-сервера (из `terraform output`) |
| `SERVER_USER` | SSH-пользователь (обычно `ec2-user`) |
| `SSH_PRIVATE_KEY` | Приватный SSH-ключ для доступа к серверу |

---

## 📋 Как посмотреть GitHub Actions

1. Перейдите на страницу **Actions**: [https://github.com/zaburdaev/my-devops-project/actions](https://github.com/zaburdaev/my-devops-project/actions)
2. Выберите последний workflow run для просмотра деталей
3. Кликните на конкретный job (Run Tests / Build & Push / Deploy) для просмотра логов

---

## 🔗 Полезные ссылки

| Раздел | Ссылка |
|--------|--------|
| **Репозиторий** | [github.com/zaburdaev/my-devops-project](https://github.com/zaburdaev/my-devops-project) |
| **Actions (CI/CD)** | [Actions](https://github.com/zaburdaev/my-devops-project/actions) |
| **Settings → Secrets** | [Secrets & Variables](https://github.com/zaburdaev/my-devops-project/settings/secrets/actions) |
| **Workflow файл** | [ci-cd.yml](https://github.com/zaburdaev/my-devops-project/blob/main/.github/workflows/ci-cd.yml) |
| **Docker Hub образ** | [oskalibriya/health-dashboard](https://hub.docker.com/r/oskalibriya/health-dashboard) |

---

## 🚀 Структура CI/CD Pipeline

```
Push to main → [Run Tests] → [Build & Push Docker Image] → [Deploy to Server]
                   │                    │                          │
              pytest + flake8    Docker build + push        SSH deploy
                                  to Docker Hub           (требует сервер)
```

### Триггеры:
- **Push в main** — запускает полный пайплайн (test → build → deploy)
- **Pull Request в main** — запускает только тесты
