# 🔒 Руководство: Постоянный IP-адрес (Persistent Elastic IP)

**Автор:** Vitalii Zaburdaiev  
**Проект:** Health Dashboard | DevOpsUA6  
**Постоянный IP:** `18.197.7.122`  
**Дата:** Май 2026

---

## 📚 Содержание

1. [Что такое постоянный IP и зачем он нужен](#1-что-такое-постоянный-ip-и-зачем-он-нужен)
2. [Как это работает технически](#2-как-это-работает-технически)
3. [Что происходит при восстановлении (пошагово)](#3-что-происходит-при-восстановлении-пошагово)
4. [Что удаляется, а что сохраняется](#4-что-удаляется-а-что-сохраняется)
5. [Ручное восстановление IP (если нужно)](#5-ручное-восстановление-ip-если-нужно)
6. [Устранение неполадок (Troubleshooting)](#6-устранение-неполадок-troubleshooting)
7. [Часто задаваемые вопросы](#7-часто-задаваемые-вопросы)

---

## 1. Что такое постоянный IP и зачем он нужен

### Проблема ДО (раньше)

Раньше при каждом восстановлении инфраструктуры (recovery) **IP-адрес менялся**:

```
Восстановление #1 → IP: 3.120.45.67
Восстановление #2 → IP: 18.196.88.12
Восстановление #3 → IP: 52.59.112.34
```

Это создавало проблемы:
- ❌ Нужно вручную обновлять `SERVER_HOST` в GitHub Secrets
- ❌ Все закладки и ссылки на приложение ломались
- ❌ DNS-записи (если были) становились неактуальными
- ❌ Мониторинг терял связь с сервером

### Решение ПОСЛЕ (сейчас)

Теперь Elastic IP **никогда не удаляется** при восстановлении:

```
Восстановление #1 → IP: 18.197.7.122 ← ВСЕГДА ОДИН И ТОТ ЖЕ
Восстановление #2 → IP: 18.197.7.122 ← ВСЕГДА ОДИН И ТОТ ЖЕ
Восстановление #3 → IP: 18.197.7.122 ← ВСЕГДА ОДИН И ТОТ ЖЕ
```

Преимущества:
- ✅ IP никогда не меняется
- ✅ `SERVER_HOST` в GitHub Secrets обновляется автоматически, но значение остаётся тем же
- ✅ Все ссылки и закладки продолжают работать
- ✅ Мониторинг не теряет связь

---

## 2. Как это работает технически

### Два уровня защиты

#### Защита №1: Terraform `prevent_destroy`

В файле `terraform/main.tf` добавлен блок `lifecycle`:

```hcl
resource "aws_eip" "app_eip" {
  domain = "vpc"

  lifecycle {
    # Запрещает Terraform удалять этот ресурс
    prevent_destroy = true

    # Игнорирует изменения привязки к инстансу
    ignore_changes = [
      instance,
      network_interface,
      associate_with_private_ip
    ]
  }

  tags = {
    Name    = "health-dashboard-eip"
    Project = "my-devops-project"
  }
}
```

**Что это делает:**
- `prevent_destroy = true` — Terraform **откажется** удалять Elastic IP, даже если получит такую команду
- `ignore_changes` — Terraform **не будет** пытаться пересоздать EIP из-за изменений привязки

#### Защита №2: Recovery Workflow пропускает EIP

В файле `.github/workflows/infrastructure-recovery.yml` этап очистки **не трогает** Elastic IP:

```yaml
- name: 🧹 Clean orphaned AWS resources (AWS CLI)
  run: |
    # Удаляем EC2 инстансы — ДА
    # Удаляем Key Pair — ДА
    # Удаляем Security Group — ДА
    # Удаляем Elastic IP — НЕТ! Сохраняем!
    echo "=== Keeping Elastic IP untouched (persistent IP mode) ==="
```

### Схема защиты

```
┌─────────────────────────────────────────────────────────┐
│                    ELASTIC IP: 18.197.7.122             │
│                                                         │
│  ┌─────────────────────┐  ┌──────────────────────────┐  │
│  │  ЗАЩИТА №1          │  │  ЗАЩИТА №2               │  │
│  │  Terraform          │  │  Recovery Workflow        │  │
│  │                     │  │                           │  │
│  │  prevent_destroy:   │  │  Шаг очистки:            │  │
│  │  true               │  │  EIP не удаляется        │  │
│  │                     │  │                           │  │
│  │  ignore_changes:    │  │  Вместо удаления:        │  │
│  │  [instance, ...]    │  │  "Keeping EIP untouched" │  │
│  └─────────────────────┘  └──────────────────────────┘  │
│                                                         │
│  Результат: IP НЕВОЗМОЖНО случайно удалить              │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Что происходит при восстановлении (пошагово)

### Шаг 1: Запуск Recovery Workflow

Администратор нажимает **"Run workflow"** в GitHub Actions.

### Шаг 2: Очистка старых ресурсов

```
🧹 Очистка (AWS CLI)
│
├── ❌ Terminate EC2 Instance
│   └── Старый инстанс уничтожается
│
├── ❌ Delete Key Pair
│   └── SSH ключ удаляется
│
├── ❌ Delete Security Group
│   └── Правила фаервола удаляются
│
└── ✅ Elastic IP СОХРАНЯЕТСЯ!
    └── 18.197.7.122 остаётся в AWS
    └── Просто отвязывается от старого инстанса
```

### Шаг 3: Terraform создаёт новую инфраструктуру

```
🔧 Terraform Apply
│
├── ✨ Новый Key Pair
│   └── Генерируется новый SSH ключ
│
├── ✨ Новый Security Group
│   └── Создаются правила фаервола
│
├── ✨ Новый EC2 Instance
│   └── Запускается новый сервер
│
├── ♻️ Elastic IP — ПЕРЕИСПОЛЬЗУЕТСЯ!
│   └── Terraform видит: "EIP уже есть в state, не трогаю"
│
└── 🔗 EIP Association — ОБНОВЛЯЕТСЯ
    └── 18.197.7.122 привязывается к НОВОМУ инстансу
```

### Шаг 4: Деплой приложения

```
🚀 Deploy
│
├── SSH на 18.197.7.122 (тот же IP!)
├── git clone репозитория
├── docker compose up -d --build
└── ✅ Приложение работает на том же IP
```

### Шаг 5: Обновление секретов

```
🔑 GitHub Secrets
│
├── SERVER_HOST = 18.197.7.122 (не изменился!)
├── SSH_PRIVATE_KEY = новый ключ (обновлён)
└── SERVER_USER = ec2-user (не изменился)
```

### Итоговая диаграмма

```
БЫЛО (до изменений):                    СТАЛО (сейчас):
═══════════════════                     ═══════════════

Recovery запуск                          Recovery запуск
      │                                       │
      ▼                                       ▼
Удалить ВСЁ:                            Удалить ЧАСТИЧНО:
├── EC2 ❌                               ├── EC2 ❌
├── Key Pair ❌                          ├── Key Pair ❌
├── Security Group ❌                    ├── Security Group ❌
├── Elastic IP ❌ ← ПРОБЛЕМА!           └── Elastic IP ✅ СОХРАНЁН!
      │                                       │
      ▼                                       ▼
Terraform создаёт:                       Terraform создаёт:
├── Новый EC2                            ├── Новый EC2
├── Новый Key Pair                       ├── Новый Key Pair
├── Новый SG                             ├── Новый SG
├── НОВЫЙ IP ← 😱                       └── Привязывает СТАРЫЙ IP ✅
      │                                       │
      ▼                                       ▼
IP ИЗМЕНИЛСЯ!                            IP НЕ ИЗМЕНИЛСЯ!
Нужно обновлять всё вручную              Всё работает автоматически
```

---

## 4. Что удаляется, а что сохраняется

### Таблица ресурсов

| Ресурс | При восстановлении | Причина |
|--------|-------------------|---------|
| **EC2 Instance** | ❌ Удаляется и создаётся новый | Сервер может быть повреждён, нужен чистый |
| **Key Pair (SSH)** | ❌ Удаляется и создаётся новый | Безопасность: новый ключ при каждом восстановлении |
| **Security Group** | ❌ Удаляется и создаётся новый | Зависит от инстанса, пересоздаётся чисто |
| **Elastic IP** | ✅ **СОХРАНЯЕТСЯ** | Постоянный адрес для доступа к приложению |
| **EIP Association** | 🔄 Обновляется | Привязка EIP к новому инстансу |
| **Docker данные** | ❌ Теряются | Хранились на старом инстансе |
| **terraform.tfstate** | ✅ Сохраняется в репозитории | Terraform помнит про EIP |

### Визуально

```
┌──────────────────────────────────────────────┐
│              ПРИ ВОССТАНОВЛЕНИИ              │
│                                              │
│  ╔══════════════════════════════════════════╗ │
│  ║  🟢 СОХРАНЯЕТСЯ (Persistent)            ║ │
│  ║                                          ║ │
│  ║  • Elastic IP: 18.197.7.122             ║ │
│  ║    (Allocation ID: eipalloc-04509284...) ║ │
│  ║  • terraform.tfstate                    ║ │
│  ║  • GitHub Secrets (обновляются)         ║ │
│  ║  • Код в репозитории                    ║ │
│  ╚══════════════════════════════════════════╝ │
│                                              │
│  ╔══════════════════════════════════════════╗ │
│  ║  🔴 ПЕРЕСОЗДАЁТСЯ (Recreated)           ║ │
│  ║                                          ║ │
│  ║  • EC2 Instance (новый ID)              ║ │
│  ║  • SSH Key Pair (новый ключ)            ║ │
│  ║  • Security Group (новый ID)            ║ │
│  ║  • Docker контейнеры                    ║ │
│  ║  • Данные приложения на сервере         ║ │
│  ╚══════════════════════════════════════════╝ │
└──────────────────────────────────────────────┘
```

---

## 5. Ручное восстановление IP (если нужно)

### Сценарий: EIP был случайно удалён из AWS Console

Если кто-то вручную удалил Elastic IP через AWS Console:

#### Шаг 1: Создать новый EIP в AWS

```bash
# Через AWS CLI
aws ec2 allocate-address --domain vpc --region eu-central-1 \
  --tag-specifications 'ResourceType=elastic-ip-address,Tags=[{Key=Name,Value=health-dashboard-eip},{Key=Project,Value=my-devops-project}]'
```

#### Шаг 2: Привязать к инстансу

```bash
# Получить Allocation ID нового EIP
ALLOC_ID=$(aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=health-dashboard-eip" \
  --query 'Addresses[0].AllocationId' --output text)

# Привязать к инстансу
aws ec2 associate-address \
  --instance-id i-08c0b5da779c84e57 \
  --allocation-id $ALLOC_ID
```

#### Шаг 3: Импортировать в Terraform State

```bash
cd terraform/

# Удалить старую запись из state
terraform state rm aws_eip.app_eip
terraform state rm aws_eip_association.app_eip_assoc

# Импортировать новый EIP
terraform import aws_eip.app_eip $ALLOC_ID

# Импортировать привязку
terraform import aws_eip_association.app_eip_assoc $ALLOC_ID
```

#### Шаг 4: Обновить GitHub Secrets

```bash
# Получить новый IP
NEW_IP=$(aws ec2 describe-addresses \
  --allocation-ids $ALLOC_ID \
  --query 'Addresses[0].PublicIp' --output text)

echo "Новый постоянный IP: $NEW_IP"
# Обновить SERVER_HOST в GitHub → Settings → Secrets
```

#### Шаг 5: Проверить

```bash
terraform plan
# Должно показать: "No changes. Your infrastructure matches the configuration."
```

---

## 6. Устранение неполадок (Troubleshooting)

### Проблема: Terraform хочет удалить/пересоздать EIP

**Симптом:** `terraform plan` показывает `destroy` для `aws_eip.app_eip`

**Причина:** `prevent_destroy = true` НЕ ДАСТ этого сделать. Terraform выдаст ошибку:
```
Error: Instance cannot be destroyed
  aws_eip.app_eip has lifecycle.prevent_destroy set
```

**Решение:** Это работает как задумано! EIP защищён. Если действительно нужно заменить EIP — уберите `prevent_destroy` из `main.tf` (временно).

---

### Проблема: EIP существует в AWS, но не в terraform.tfstate

**Симптом:** Terraform хочет создать новый EIP, хотя старый уже есть.

**Решение:**
```bash
# 1. Найти Allocation ID существующего EIP
aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=health-dashboard-eip" \
  --query 'Addresses[0].AllocationId' --output text

# 2. Импортировать в state
terraform import aws_eip.app_eip eipalloc-XXXXXXXXXXXXXXXXX
```

---

### Проблема: EIP не привязан к инстансу после восстановления

**Симптом:** Инстанс работает, EIP существует, но не привязан.

**Решение:**
```bash
# Привязать вручную
aws ec2 associate-address \
  --instance-id <INSTANCE_ID> \
  --allocation-id eipalloc-04509284aae88c6a3

# Или запустить terraform apply
cd terraform/
terraform apply
```

---

### Проблема: Recovery workflow упал с ошибкой

**Что проверить:**
1. Посмотреть логи в GitHub Actions → вкладка "Actions"
2. Проверить статус EIP в AWS Console → EC2 → Elastic IPs
3. Проверить, что `terraform.tfstate` в репозитории актуален

---

### Проблема: Приложение недоступно после recovery

**Чек-лист:**
```bash
# 1. Проверить, что EIP привязан
aws ec2 describe-addresses --filters "Name=tag:Name,Values=health-dashboard-eip"

# 2. Проверить, что инстанс запущен
aws ec2 describe-instances --filters "Name=tag:Project,Values=my-devops-project" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]'

# 3. Подключиться по SSH и проверить контейнеры
ssh -i my-devops-key.pem ec2-user@18.197.7.122
docker compose ps

# 4. Проверить приложение
curl http://18.197.7.122
curl http://18.197.7.122:3000/api/health
curl http://18.197.7.122:9090/-/healthy
```

---

## 7. Часто задаваемые вопросы

### ❓ Может ли IP измениться?

**Нет**, пока Elastic IP существует в AWS. Он защищён двумя механизмами:
1. Terraform `prevent_destroy` — блокирует удаление через Terraform
2. Recovery workflow — не трогает EIP при очистке

### ❓ Что если я случайно удалю EIP через AWS Console?

IP будет потерян безвозвратно. AWS не гарантирует повторное выделение того же IP. Нужно будет:
1. Создать новый EIP
2. Импортировать в Terraform state
3. Обновить документацию и GitHub Secrets

### ❓ Стоит ли EIP денег?

- **Бесплатно**, пока EIP привязан к работающему инстансу
- **~$3.65/месяц**, если EIP существует, но НЕ привязан (инстанс остановлен/удалён)

### ❓ Могу ли я сменить IP на другой?

Да, но это потребует ручных действий:
1. Убрать `prevent_destroy` из `main.tf`
2. `terraform destroy` для EIP
3. Вернуть `prevent_destroy`
4. `terraform apply` — создаст новый EIP

### ❓ Allocation ID нашего EIP?

```
Allocation ID: eipalloc-04509284aae88c6a3
Public IP:     18.197.7.122
Region:        eu-central-1 (Frankfurt)
```

---

## 📝 Итоги

```
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║  🔒 IP-адрес 18.197.7.122 — ПОСТОЯННЫЙ              ║
║                                                       ║
║  • Защищён prevent_destroy в Terraform               ║
║  • Не удаляется при Recovery                         ║
║  • Автоматически привязывается к новому серверу      ║
║  • Не требует ручного обновления GitHub Secrets      ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
```
