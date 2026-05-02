# ♻️ INFRASTRUCTURE_RECOVERY_RU

Полное руководство по восстановлению инфраструктуры проекта **Health Dashboard**.

---

## 1) Что такое Elastic IP и зачем он нужен

**Elastic IP (EIP)** — это статический публичный IPv4-адрес в AWS.

### Почему это важно

Обычный public IP EC2 может измениться после:
- остановки/запуска инстанса,
- пересоздания ресурса,
- аварийного восстановления.

Из-за этого ломаются:
- `SERVER_HOST` в GitHub Secrets,
- SSH-деплой из GitHub Actions,
- ссылки в документации.

### Что даёт EIP

- Постоянный адрес для доступа к сервисам.
- Стабильный endpoint для CI/CD.
- Предсказуемое восстановление после инцидентов.

Текущий статический IP проекта:
- `18.156.160.162`

Проверка через Terraform:

```bash
cd terraform
terraform output -raw elastic_ip
```

---

## 2) Как вручную запустить Recovery из GitHub Actions

1. Открой репозиторий:  
   `https://github.com/zaburdaev/my-devops-project`
2. Перейди в **Actions**.
3. Выбери workflow **Infrastructure Recovery**.
4. Нажми **Run workflow**.
5. Выбери ветку `main`.
6. Подтверди запуск.

Workflow файл:
- `.github/workflows/infrastructure-recovery.yml`

---

## 3) Что происходит во время recovery

Workflow выполняет следующие шаги:

1. Checkout репозитория.
2. Установка Terraform.
3. Подключение AWS credentials из GitHub Secrets.
4. `terraform init` и `terraform apply -auto-approve`.
5. Получение `elastic_ip` из Terraform output.
6. Обновление `SERVER_HOST` в GitHub Secrets.
7. SSH-подключение к серверу.
8. Обновление кода (`git pull origin main`).
9. Запуск стека: `docker compose up -d --build`.

Итог: инфраструктура и приложение автоматически возвращаются в рабочее состояние.

---

## 4) Как проверить, что recovery успешен

### Проверка GitHub Actions

- Статус workflow: ✅ Success
- Без ошибок в шагах Terraform и SSH deploy.

### Проверка Terraform outputs

```bash
cd terraform
terraform output elastic_ip
terraform output app_url
terraform output grafana_url
terraform output prometheus_url
```

### Проверка сервисов

```bash
curl http://18.156.160.162/health
curl http://18.156.160.162:9090/-/ready
curl http://18.156.160.162:3000/api/health
```

Ожидаемо:
- `/health` → JSON со статусом `healthy`
- Prometheus `/-/ready` → `Prometheus is Ready`
- Grafana `/api/health` → JSON с `"database":"ok"`

### Проверка мониторинга

- Grafana: `http://18.156.160.162:3000`
- Prometheus: `http://18.156.160.162:9090/targets`
- Target `flask-app` должен быть **UP**.

---

## 5) Troubleshooting (типовые проблемы)

### Проблема: Terraform не может создать/прочитать ресурсы

Причины:
- неверные/просроченные AWS credentials,
- недостаточные IAM permissions.

Что делать:
- проверить `AWS_ACCESS_KEY_ID` и `AWS_SECRET_ACCESS_KEY` в GitHub Secrets,
- проверить права EC2/IAM (Describe/Create/Associate EIP, EC2, SG, KeyPair).

---

### Проблема: SSH deploy падает

Причины:
- неверный `SSH_PRIVATE_KEY`,
- `SERVER_HOST` не обновился,
- порт 22 закрыт в Security Group.

Что делать:
- проверить секреты `SSH_PRIVATE_KEY`, `SERVER_HOST`, `SERVER_USER`,
- убедиться, что SG допускает вход на `22/tcp`.

---

### Проблема: Grafana открывается, но "No Data"

Проверки:
1. `http://18.156.160.162:9090/targets` — `flask-app` должен быть UP.
2. В Grafana есть datasource `Prometheus` (Loki удалён в оптимизированной конфигурации).
3. В контейнерах смонтирован каталог `./monitoring/grafana/provisioning`.

Команды на сервере:

```bash
cd /opt/health-dashboard
docker compose ps
docker compose logs prometheus --tail=100
docker compose logs grafana --tail=100
curl http://localhost:5000/metrics
```

---

### Проблема: после recovery изменился IP

Если используешь Elastic IP правильно, внешний IP не должен «прыгать».  
Проверь:
- наличие `aws_eip` и `aws_eip_association` в `terraform/main.tf`,
- что в документации и секретах используется именно `elastic_ip`.

---

## 6) Рекомендации для учебного проекта (Free Tier)

Чтобы не выйти за бесплатные лимиты:
- использовать `t3.micro`,
- удалять инфраструктуру после проверки: `terraform destroy -auto-approve`,
- не держать лишние EIP/диски/инстансы,
- регулярно смотреть Billing Dashboard AWS.

---

## 7) Связанные документы

- [README_RU.md](../README_RU.md)
- [DEPLOYMENT_SUMMARY.md](../DEPLOYMENT_SUMMARY.md)
- [AWS_DEPLOYMENT_RU.md](./AWS_DEPLOYMENT_RU.md)
- [MONITORING.md](./MONITORING.md)
- [CI_CD.md](./CI_CD.md)

---
