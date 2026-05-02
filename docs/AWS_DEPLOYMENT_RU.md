# 🚀 Деплой AWS инфраструктуры — Полное руководство

> **Автор:** Vitalii Zaburdaiev | DevOpsUA6  
> **Проект:** Health Dashboard (my-devops-project)  
> **Регион AWS:** eu-central-1 (Франкфурт, Германия)

---

## 📋 Содержание

1. [Что такое AWS и зачем это нужно](#1--что-такое-aws-и-зачем-это-нужно)
2. [Что создаёт Terraform в AWS](#2--что-создаёт-terraform-в-aws)
3. [Как развернуть инфраструктуру](#3--как-развернуть-инфраструктуру)
4. [Как подключиться к серверу](#4--как-подключиться-к-серверу)
5. [Как задеплоить приложение на сервер](#5--как-задеплоить-приложение-на-сервер)
6. [Как удалить инфраструктуру (важно!)](#6--как-удалить-инфраструктуру-важно)
7. [Стоимость и лимиты](#7--стоимость-и-лимиты)
8. [Частые проблемы и решения](#8--частые-проблемы-и-решения)

---

## 1. 🌐 Что такое AWS и зачем это нужно

### Что такое AWS?

**Amazon Web Services (AWS)** — это облачная платформа от Amazon, которая предоставляет вычислительные ресурсы через интернет. Вместо покупки физического сервера, вы арендуете виртуальный сервер в дата-центре Amazon.

**Простая аналогия:** Представьте, что вам нужен офис для работы. Вы можете:
- 🏗️ Построить свой офис (купить физический сервер) — дорого и долго
- 🏢 Арендовать офис (использовать AWS) — быстро, гибко, платите только за использование

### Зачем деплоить в облако?

| Преимущество | Описание |
|---|---|
| **Доступность** | Ваше приложение доступно из любой точки мира 24/7 |
| **Масштабируемость** | Можно увеличить мощность сервера в несколько кликов |
| **Надёжность** | Amazon гарантирует 99.99% доступности |
| **Безопасность** | AWS имеет сертификации ISO 27001, SOC 2 и другие |
| **Экономия** | Платите только за то, что используете |

### Что такое EC2?

**EC2 (Elastic Compute Cloud)** — это сервис AWS, который предоставляет виртуальные серверы (инстансы). Можно думать о EC2 как о "компьютере в облаке".

```
┌─────────────────────────────────────────┐
│              AWS Cloud                   │
│  ┌──────────────────────────────────┐   │
│  │     EC2 Instance (t3.micro)      │   │
│  │  ┌────────────────────────────┐  │   │
│  │  │  Amazon Linux 2023         │  │   │
│  │  │  Docker + Docker Compose   │  │   │
│  │  │  Health Dashboard App      │  │   │
│  │  └────────────────────────────┘  │   │
│  │  CPU: 2 vCPU | RAM: 1GB         │   │
│  │  Disk: 30GB gp3                  │   │
│  └──────────────────────────────────┘   │
│  Public IP: xx.xx.xx.xx                 │
└─────────────────────────────────────────┘
```

---

## 2. 🏗️ Что создаёт Terraform в AWS

Terraform — это инструмент **Infrastructure as Code (IaC)**. Вместо того чтобы создавать ресурсы вручную в AWS Console, мы описываем всё в коде.

### Создаваемые ресурсы

#### 2.1 🔑 SSH Key Pair (Ключ для доступа)

```hcl
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "my-devops-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
```

**Что это делает:**
- Генерирует RSA-4096 ключевую пару (приватный + публичный ключ)
- Загружает публичный ключ в AWS
- Приватный ключ используется для подключения по SSH

**Аналогия:** Это как ключ от входной двери вашего офиса (сервера). Публичный ключ — это замок на двери, приватный ключ — это ваш ключ.

#### 2.2 🛡️ Security Group (Правила Firewall)

```hcl
resource "aws_security_group" "health_dashboard_sg" {
  name        = "health-dashboard-sg"
  description = "Security group for Health Dashboard application"

  # Открытые порты:
  # 22   - SSH (для подключения к серверу)
  # 80   - HTTP (веб-приложение)
  # 443  - HTTPS (безопасное соединение)
  # 3000 - Grafana (мониторинг)
  # 9090 - Prometheus (метрики)
}
```

**Что это делает:**
- Определяет какой трафик разрешён к серверу
- Работает как файрвол (firewall)

**Открытые порты:**

| Порт | Сервис | Описание |
|------|--------|----------|
| 22 | SSH | Удалённое подключение к серверу |
| 80 | HTTP | Веб-приложение Health Dashboard |
| 443 | HTTPS | Защищённое веб-соединение |
| 3000 | Grafana | Дашборды мониторинга |
| 9090 | Prometheus | Сбор метрик |

#### 2.3 🖥️ EC2 Instance (Виртуальный сервер)

```hcl
resource "aws_instance" "health_dashboard" {
  ami           = data.aws_ami.amazon_linux.id  # Amazon Linux 2023
  instance_type = "t3.micro"                     # Free Tier!
  key_name      = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size = 30    # 30 ГБ диска
    volume_type = "gp3" # Быстрый SSD
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
  EOF
}
```

**Что это делает:**
- Создаёт виртуальный сервер с Amazon Linux 2023
- Тип `t3.micro`: 2 vCPU, 1 ГБ RAM (Free Tier)
- Диск 30 ГБ SSD (gp3)
- Автоматически устанавливает Docker при запуске (user_data)

### Схема инфраструктуры

```
Интернет
    │
    ▼
┌─────────────┐
│ Security    │  ← Firewall: порты 22, 80, 443, 3000, 9090
│ Group       │
└──────┬──────┘
       │
┌──────▼──────┐
│ EC2 Instance│  ← t3.micro, Amazon Linux 2023
│             │
│ ┌─────────┐ │
│ │ Docker  │ │  ← Контейнеры с приложением
│ │ Compose │ │
│ └─────────┘ │
└──────┬──────┘
       │
┌──────▼──────┐
│ SSH Key Pair│  ← Доступ по SSH
└─────────────┘
```

---

## 3. 📝 Как развернуть инфраструктуру

### Предварительные требования

1. **AWS аккаунт** с Access Key и Secret Key
2. **Terraform** установлен (`>= 1.0`)
3. **AWS CLI** настроен (опционально)

### Шаг 1: Настройка AWS Credentials

```bash
# Вариант 1: Через переменные окружения
export AWS_ACCESS_KEY_ID="ваш-access-key"
export AWS_SECRET_ACCESS_KEY="ваш-secret-key"
export AWS_DEFAULT_REGION="eu-central-1"

# Вариант 2: Через AWS CLI
aws configure
# Введите Access Key, Secret Key, Region: eu-central-1
```

**Проверка:**
```bash
aws sts get-caller-identity
# Должен вернуть JSON с AccountId и Arn
```

### Шаг 2: Инициализация Terraform

```bash
cd terraform/
terraform init
```

**Что происходит:**
- Скачиваются провайдеры (AWS, TLS)
- Создаётся директория `.terraform/`
- Создаётся lock-файл `.terraform.lock.hcl`

### Шаг 3: Проверка конфигурации

```bash
terraform validate
```

**Что происходит:**
- Terraform проверяет синтаксис всех `.tf` файлов
- Не делает запросов к AWS
- Проверяет, что все переменные и ресурсы определены правильно

### Шаг 4: Планирование (предварительный просмотр)

```bash
terraform plan
```

**Что происходит:**
- Terraform показывает, какие ресурсы будут созданы/изменены/удалены
- Это **сухой прогон** — ничего не создаётся
- Позволяет увидеть изменения ДО их применения

**Пример вывода:**
```
Plan: 4 to add, 0 to change, 0 to destroy.
```

Это значит: будут созданы 4 ресурса (TLS ключ, Key Pair, Security Group, EC2 Instance).

### Шаг 5: Деплой (создание ресурсов)

```bash
terraform apply -auto-approve
```

**Что происходит:**
1. Генерируется SSH ключ (TLS Private Key)
2. Создаётся Key Pair в AWS
3. Создаётся Security Group с правилами файрвола
4. Создаётся EC2 Instance
5. На EC2 запускается user_data скрипт (установка Docker)

**⏱️ Время:** ~30-60 секунд

**Важные данные в выводе:**
```
Outputs:
  instance_public_ip  = "xx.xx.xx.xx"    ← IP адрес сервера
  app_url             = "http://xx.xx.xx.xx"
  grafana_url         = "http://xx.xx.xx.xx:3000"
  ssh_command         = "ssh -i my-devops-key.pem ec2-user@xx.xx.xx.xx"
```

### Шаг 6: Сохранение SSH ключа

```bash
# Сохранить приватный ключ в файл
terraform output -raw ssh_private_key > my-devops-key.pem
chmod 600 my-devops-key.pem

# Сохранить IP адрес
terraform output -raw instance_public_ip > ../server_ip.txt
```

---

## 4. 🔌 Как подключиться к серверу

### Получение IP адреса

```bash
# Вариант 1: Из Terraform
cd terraform/
terraform output instance_public_ip

# Вариант 2: Из сохранённого файла
cat server_ip.txt

# Вариант 3: Через AWS CLI
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=health-dashboard-server" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text
```

### Подключение по SSH

```bash
# Подключение к серверу
ssh -i my-devops-key.pem ec2-user@<IP_АДРЕС>

# Пример:
ssh -i my-devops-key.pem ec2-user@18.156.160.162
```

**⚠️ Важно:**
- Файл ключа должен иметь права `600`: `chmod 600 my-devops-key.pem`
- Пользователь на сервере: `ec2-user` (не `root`!)
- Для sudo команд используйте `sudo` перед командой

### Что делать на сервере

```bash
# Проверить статус Docker
docker --version
docker compose version

# Посмотреть запущенные контейнеры
docker ps

# Посмотреть логи
docker compose logs -f

# Проверить ресурсы
free -h     # RAM
df -h       # Диск
uptime      # Загрузка CPU
```

---

## 5. 📦 Как задеплоить приложение на сервер

### Вариант 1: Использование Ansible (рекомендуемый)

**Ansible** — инструмент автоматизации, который настраивает сервер по описанию (playbook).

#### Шаг 1: Обновить IP в inventory

```bash
# Файл: ansible/inventory.ini
[webservers]
health-dashboard ansible_host=<SERVER_IP> ansible_user=ec2-user ansible_ssh_private_key_file=../my-devops-key.pem
```

#### Шаг 2: Запустить playbook

```bash
cd ansible/
ansible-playbook -i inventory.ini playbook.yml
```

**Что делает Ansible:**
1. Обновляет системные пакеты
2. Устанавливает Docker и Docker Compose (если не установлены)
3. Настраивает firewall (порты)
4. Копирует docker-compose.yml и конфигурацию на сервер
5. Запускает `docker-compose up -d`
6. Проверяет, что приложение работает

### Вариант 2: Ручной деплой через SSH

```bash
# 1. Подключиться к серверу
ssh -i my-devops-key.pem ec2-user@<SERVER_IP>

# 2. Создать директорию проекта
sudo mkdir -p /opt/health-dashboard
cd /opt/health-dashboard

# 3. Скопировать файлы (с локальной машины)
# В отдельном терминале:
scp -i my-devops-key.pem -r docker-compose.yml .env monitoring/ nginx/ ec2-user@<SERVER_IP>:/opt/health-dashboard/

# 4. Запустить приложение
docker-compose up -d

# 5. Проверить статус
docker-compose ps
curl localhost:5000/health
```

### Вариант 3: Через CI/CD (GitHub Actions) — автоматический деплой

При пуше в `main` ветку, GitHub Actions автоматически:
1. Запускает тесты
2. Собирает Docker образ
3. Деплоит на сервер по SSH

> 💡 **Первый деплой выполняется автоматически!** Workflow сам создаст директорию `/opt/health-dashboard`, склонирует репозиторий, создаст `.env` файл и запустит приложение. Не нужно предварительно настраивать сервер вручную (если Docker и Docker Compose уже установлены).

> 💡 **Совет:** Рекомендуется сначала запустить Ansible playbook (`ansible-playbook -i inventory.ini playbook.yml`), который установит Docker и Docker Compose, а затем CI/CD будет автоматически деплоить обновления.

Для работы CI/CD нужно настроить GitHub Secrets:
- `SERVER_HOST` — IP адрес сервера
- `SERVER_USER` — `ec2-user`
- `SSH_PRIVATE_KEY` — содержимое файла `my-devops-key.pem`

Подробнее об ошибках CI/CD и их решениях: [Руководство по устранению неполадок](./TROUBLESHOOTING_RU.md)

---

## 6. ⚠️ Как удалить инфраструктуру (ВАЖНО!)

### Зачем удалять?

> **💰 AWS выставляет счёт за работающие ресурсы!** Даже если вы не используете сервер, вы платите за него каждый час.

EC2 t3.micro стоит ~$0.01/час. Если забыть удалить, за месяц набежит ~$7-8.

### Как удалить

```bash
cd terraform/
terraform destroy -auto-approve
```

**Что происходит:**
1. Удаляется EC2 Instance (виртуальный сервер)
2. Удаляется Security Group
3. Удаляется Key Pair
4. Все данные на сервере будут ПОТЕРЯНЫ

**⏱️ Время:** ~30-60 секунд

### Проверка удаления

```bash
# Проверить, что ресурсов нет
terraform show
# Должен вернуть пустой результат

# Или через AWS CLI
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=health-dashboard-server" \
  --query "Reservations[].Instances[].State.Name"
# Должен быть "terminated" или пустой массив
```

### ⚠️ Чек-лист перед удалением

- [ ] Сохранены ли данные/логи с сервера?
- [ ] Больше не нужен сервер для демонстрации?
- [ ] Обновлены ли GitHub Secrets (удалить SERVER_HOST)?

---

## 7. 💰 Стоимость и лимиты

### AWS Free Tier

AWS предоставляет **12 месяцев бесплатного использования** для новых аккаунтов.

| Ресурс | Бесплатный лимит | Наш проект |
|--------|-------------------|------------|
| EC2 t3.micro | 750 часов/месяц | ✅ Укладываемся |
| EBS (gp3) | 30 ГБ | ✅ Ровно 30 ГБ |
| Data Transfer | 100 ГБ/месяц (выход) | ✅ Достаточно |
| Elastic IP | 1 бесплатно (если привязан) | ❌ Не используем |

### Сколько стоит, если Free Tier закончился

| Ресурс | Цена (eu-central-1) | Месяц |
|--------|---------------------|-------|
| EC2 t3.micro | $0.0116/час | ~$8.35 |
| EBS 30GB gp3 | $0.0952/ГБ/мес | ~$2.86 |
| Data Transfer | $0.09/ГБ | ~$1-5 |
| **Итого** | | **~$12-16/мес** |

### Как не потратить деньги

1. **Удаляйте ресурсы** после использования: `terraform destroy`
2. **Настройте AWS Budget** — уведомление при превышении суммы:
   ```
   AWS Console → Billing → Budgets → Create Budget
   Set threshold: $5/month
   ```
3. **Используйте Free Tier** — первый год EC2 t3.micro бесплатно (750 ч/мес)
4. **Не оставляйте сервер на ночь** без надобности
5. **Проверяйте AWS Console** регулярно: `Billing Dashboard`

---

## 8. 🔧 Частые проблемы и решения

### ❌ Проблема: AWS Credentials не работают

**Симптомы:**
```
Error: No valid credential sources found
Error: operation error STS: GetCallerIdentity
```

**Решения:**

1. Проверьте, что credentials настроены:
   ```bash
   aws sts get-caller-identity
   ```

2. Проверьте переменные окружения:
   ```bash
   echo $AWS_ACCESS_KEY_ID
   echo $AWS_DEFAULT_REGION
   ```

3. Проверьте файл `~/.aws/credentials`:
   ```bash
   cat ~/.aws/credentials
   ```

4. Убедитесь, что ключи правильные (без пробелов, кавычек):
   ```bash
   export AWS_ACCESS_KEY_ID="AKIA..."
   export AWS_SECRET_ACCESS_KEY="..."
   export AWS_DEFAULT_REGION="eu-central-1"
   ```

### ❌ Проблема: terraform apply падает

**Симптом 1: "InvalidBlockDeviceMapping"**
```
Volume of size 20GB is smaller than snapshot, expect size >= 30GB
```
**Решение:** Увеличьте `volume_size` до 30 в `main.tf`.

**Симптом 2: "InvalidParameterCombination" (instance type)**
```
The specified instance type is not eligible for Free Tier
```
**Решение:** Используйте `t3.micro` вместо `t2.micro` в `variables.tf`.

**Симптом 3: "UnauthorizedOperation"**
```
You are not authorized to perform this operation
```
**Решение:** Ваш AWS пользователь не имеет достаточных прав. Нужны права на EC2, VPC, Key Pair.

**Симптом 4: "InvalidKeyPair.Duplicate"**
```
The keypair already exists
```
**Решение:**
```bash
# Удалить существующий ключ
aws ec2 delete-key-pair --key-name my-devops-key
# Попробовать снова
terraform apply
```

### ❌ Проблема: Не могу подключиться к серверу по SSH

**Решения:**

1. **Подождите 1-2 минуты** — сервер может ещё загружаться
   ```bash
   # Проверить статус
   aws ec2 describe-instance-status --instance-ids <INSTANCE_ID>
   ```

2. **Проверьте IP адрес:**
   ```bash
   terraform output instance_public_ip
   ```

3. **Проверьте права на ключ:**
   ```bash
   chmod 600 my-devops-key.pem
   ```

4. **Проверьте пользователя** — должен быть `ec2-user`:
   ```bash
   ssh -i my-devops-key.pem ec2-user@<IP>
   # НЕ root, НЕ ubuntu!
   ```

5. **Проверьте Security Group** — порт 22 должен быть открыт:
   ```bash
   aws ec2 describe-security-groups --group-names health-dashboard-sg \
     --query "SecurityGroups[0].IpPermissions"
   ```

6. **Подробный вывод SSH:**
   ```bash
   ssh -vvv -i my-devops-key.pem ec2-user@<IP>
   ```

### ❌ Проблема: Приложение не работает после деплоя

1. **Проверьте Docker контейнеры:**
   ```bash
   ssh -i my-devops-key.pem ec2-user@<IP>
   docker ps
   docker compose logs
   ```

2. **Проверьте порты:**
   ```bash
   curl localhost:5000/health
   curl localhost:80
   ```

3. **Проверьте .env файл:**
   ```bash
   cat /opt/health-dashboard/.env
   ```

---

## 📚 Полезные команды

### Terraform
```bash
terraform init          # Инициализация
terraform plan          # Предпросмотр изменений
terraform apply         # Применить изменения
terraform destroy       # Удалить всё
terraform output        # Показать outputs
terraform show          # Показать текущее состояние
terraform state list    # Список ресурсов
```

### AWS CLI
```bash
aws sts get-caller-identity              # Проверка credentials
aws ec2 describe-instances               # Список EC2 инстансов
aws ec2 describe-security-groups         # Список Security Groups
aws ec2 describe-key-pairs               # Список SSH ключей
```

### SSH
```bash
ssh -i key.pem user@ip                   # Подключение
scp -i key.pem file user@ip:/path        # Копирование файла
ssh -i key.pem user@ip "command"         # Выполнение команды
```

---

## 📊 Информация о текущем деплое

| Параметр | Значение |
|----------|----------|
| **Region** | eu-central-1 (Frankfurt) |
| **Instance Type** | t3.micro |
| **OS** | Amazon Linux 2023 |
| **Disk** | 30 GB gp3 SSD |
| **Открытые порты** | 22, 80, 443, 3000, 9090 |
| **SSH User** | ec2-user |
| **SSH Key** | my-devops-key.pem |

---

> 💡 **Совет:** Всегда удаляйте ресурсы после использования командой `terraform destroy`, чтобы не платить за неиспользуемые серверы!



---

## 9. ♻️ Переразвёртывание после удаления EC2 (Recovery Runbook)

Если сервер был удалён (ошибка в CI/CD: `dial tcp <old_ip>:22: i/o timeout`), выполните:

```bash
cd /home/ubuntu/my-devops-project/terraform

# 1) Очистка старого состояния
terraform state list
terraform destroy -auto-approve || true

# 2) Повторный деплой инфраструктуры
terraform init
terraform plan
terraform apply -auto-approve

# 3) Сохранение ключа и IP
terraform output -raw ssh_private_key > my-devops-key.pem
chmod 600 my-devops-key.pem
terraform output -raw instance_public_ip
```

Далее обновите GitHub Secrets:
- `SERVER_HOST` = новый IP
- `SERVER_USER` = `ec2-user`
- `SSH_PRIVATE_KEY` = содержимое `my-devops-key.pem`

После этого:
1. Запустите `ansible-playbook -i inventory.ini playbook.yml` для первичного развёртывания.
2. Выполните push в `main`, чтобы проверить автоматический деплой через GitHub Actions.
3. Проверьте доступность:
   - `http://<IP>/health`
   - `http://<IP>:3000`
   - `http://<IP>:9090`
