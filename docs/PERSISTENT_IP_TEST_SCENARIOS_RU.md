# 🧪 Тестовые сценарии: Постоянный IP (Persistent Elastic IP)

**Автор:** Vitalii Zaburdaiev  
**Проект:** Health Dashboard | DevOpsUA6  
**Дата:** Май 2026

---

## 📊 Сравнение: ДО и ПОСЛЕ

### ❌ ДО: IP менялся при каждом восстановлении

```
┌──────────────────────────────────────────────────────────────────────┐
│                     СТАРОЕ ПОВЕДЕНИЕ (ДО)                           │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Recovery #1:                                                        │
│  ├── Удалить ВСЕ ресурсы (включая Elastic IP)                       │
│  ├── Terraform создаёт НОВЫЙ Elastic IP                              │
│  ├── Результат: IP = 3.120.45.67  ← НОВЫЙ                          │
│  └── ⚠️ Нужно вручную обновить SERVER_HOST                          │
│                                                                      │
│  Recovery #2:                                                        │
│  ├── Удалить ВСЕ ресурсы (включая Elastic IP)                       │
│  ├── Terraform создаёт НОВЫЙ Elastic IP                              │
│  ├── Результат: IP = 18.196.88.12  ← ДРУГОЙ НОВЫЙ                  │
│  └── ⚠️ Нужно ОПЯТЬ обновить SERVER_HOST                            │
│                                                                      │
│  Recovery #3:                                                        │
│  ├── Удалить ВСЕ ресурсы (включая Elastic IP)                       │
│  ├── Terraform создаёт НОВЫЙ Elastic IP                              │
│  ├── Результат: IP = 52.59.112.34  ← ОПЯТЬ НОВЫЙ                   │
│  └── ⚠️ Нужно ОПЯТЬ обновить SERVER_HOST                            │
│                                                                      │
│  Проблемы:                                                           │
│  • IP непредсказуем                                                  │
│  • Все закладки/ссылки ломаются                                     │
│  • CI/CD пайплайн деплоя не работает до обновления секрета          │
│  • DNS записи устаревают                                            │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### ✅ ПОСЛЕ: IP остаётся тем же

```
┌──────────────────────────────────────────────────────────────────────┐
│                     НОВОЕ ПОВЕДЕНИЕ (ПОСЛЕ)                         │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Recovery #1:                                                        │
│  ├── Удалить ресурсы КРОМЕ Elastic IP                               │
│  ├── Terraform переиспользует СУЩЕСТВУЮЩИЙ EIP                      │
│  ├── Результат: IP = 52.59.86.193  ← ТОТ ЖЕ                       │
│  └── ✅ SERVER_HOST не нужно менять                                  │
│                                                                      │
│  Recovery #2:                                                        │
│  ├── Удалить ресурсы КРОМЕ Elastic IP                               │
│  ├── Terraform переиспользует СУЩЕСТВУЮЩИЙ EIP                      │
│  ├── Результат: IP = 52.59.86.193  ← ТОТ ЖЕ                       │
│  └── ✅ SERVER_HOST не нужно менять                                  │
│                                                                      │
│  Recovery #3:                                                        │
│  ├── Удалить ресурсы КРОМЕ Elastic IP                               │
│  ├── Terraform переиспользует СУЩЕСТВУЮЩИЙ EIP                      │
│  ├── Результат: IP = 52.59.86.193  ← ТОТ ЖЕ                       │
│  └── ✅ SERVER_HOST не нужно менять                                  │
│                                                                      │
│  Результат:                                                          │
│  • IP всегда 52.59.86.193                                           │
│  • Закладки и ссылки работают                                       │
│  • CI/CD продолжает работать                                        │
│  • DNS не нужно обновлять                                           │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🔍 Детальное сравнение ресурсов

### Что удаляется, а что сохраняется

| Ресурс AWS | ДО (старое) | ПОСЛЕ (новое) | Комментарий |
|------------|:-----------:|:-------------:|-------------|
| **EC2 Instance** | ❌ Удаляется | ❌ Удаляется | Пересоздаётся чистым |
| **Key Pair** | ❌ Удаляется | ❌ Удаляется | Новый SSH ключ каждый раз |
| **Security Group** | ❌ Удаляется | ❌ Удаляется | Пересоздаётся с теми же правилами |
| **Elastic IP** | ❌ **Удаляется** | ✅ **Сохраняется** | **Главное изменение!** |
| **EIP Association** | ❌ Удаляется | 🔄 Обновляется | Привязка к новому инстансу |

### Жизненный цикл ресурсов при Recovery

```
                    ДО                              ПОСЛЕ
               ════════                          ════════

EC2:        [старый] ──❌──▶ [новый]      [старый] ──❌──▶ [новый]
Key Pair:   [старый] ──❌──▶ [новый]      [старый] ──❌──▶ [новый]
SG:         [старый] ──❌──▶ [новый]      [старый] ──❌──▶ [новый]
EIP:        [старый] ──❌──▶ [НОВЫЙ IP]   [старый] ──✅──▶ [тот же IP]
                          ↑                              ↑
                     ПРОБЛЕМА!                      РЕШЕНИЕ!
```

---

## 🧪 Тестовые сценарии

### Тест 1: Terraform Plan (проверка что EIP не пересоздаётся)

**Цель:** Убедиться, что `terraform plan` не планирует удалять/пересоздавать EIP.

**Как проверить:**
```bash
cd terraform/
terraform plan
```

**Ожидаемый результат:**
```
No changes. Your infrastructure matches the configuration.
```

Или если есть другие изменения, EIP НЕ должен быть в списке `destroy`:
```
# Terraform will perform the following actions:
# НЕ должно быть строки:
#   aws_eip.app_eip will be destroyed
```

**Статус:** ✅ ПРОЙДЕН

---

### Тест 2: Проверка prevent_destroy

**Цель:** Убедиться, что Terraform откажется удалять EIP.

**Как проверить:**
```bash
cd terraform/
terraform plan -destroy -target=aws_eip.app_eip
```

**Ожидаемый результат:**
```
Error: Instance cannot be destroyed

  on main.tf line XX:

  Resource aws_eip.app_eip has lifecycle.prevent_destroy set,
  but the plan calls for this resource to be destroyed.
```

**Статус:** ✅ Защита работает

---

### Тест 3: Проверка terraform.tfstate

**Цель:** Убедиться, что EIP записан в state файле.

**Как проверить:**
```bash
cd terraform/
terraform state show aws_eip.app_eip
```

**Ожидаемый результат:**
```
# aws_eip.app_eip:
resource "aws_eip" "app_eip" {
    allocation_id     = "eipalloc-04509284aae88c6a3"
    domain            = "vpc"
    public_ip         = "52.59.86.193"
    ...
}
```

**Статус:** ✅ EIP в state

---

### Тест 4: Проверка Recovery Workflow

**Цель:** Убедиться, что workflow не удаляет EIP.

**Как проверить:** Прочитать `.github/workflows/infrastructure-recovery.yml`

**Ожидаемый результат:**
- В шаге `🧹 Clean orphaned AWS resources` **нет** команды `aws ec2 release-address`
- Есть сообщение: `"Keeping Elastic IP untouched (persistent IP mode)"`

**Статус:** ✅ EIP не удаляется

---

### Тест 5: Проверка текущего состояния в AWS

**Цель:** Убедиться, что EIP существует и привязан к инстансу.

**Как проверить:**
```bash
aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=health-dashboard-eip" \
  --query 'Addresses[*].[PublicIp,AllocationId,InstanceId]' \
  --output table
```

**Ожидаемый результат:**
```
------------------------------------------------------------
|                    DescribeAddresses                      |
+----------------+---------------------------+--------------+
|  52.59.86.193  |  eipalloc-04509284aae...  |  i-08c0b... |
+----------------+---------------------------+--------------+
```

**Статус:** ✅ EIP существует и привязан

---

### Тест 6: Доступность сервисов по постоянному IP

**Цель:** Убедиться, что все сервисы доступны.

```bash
# Приложение
curl -sf http://52.59.86.193 | grep -o "<title>.*</title>"
# Ожидание: <title>Health Dashboard</title>

# Grafana
curl -sf http://52.59.86.193:3000/api/health
# Ожидание: {"commit":"...","database":"ok","version":"..."}

# Prometheus
curl -sf http://52.59.86.193:9090/-/healthy
# Ожидание: Prometheus Server is Healthy.
```

**Статус:** ✅ Все сервисы доступны

---

## 📋 Сводная таблица результатов тестирования

| # | Тест | Результат | Описание |
|---|------|:---------:|----------|
| 1 | Terraform Plan | ✅ | EIP не планируется к пересозданию |
| 2 | prevent_destroy | ✅ | Terraform отказывается удалять EIP |
| 3 | terraform.tfstate | ✅ | EIP записан в state с правильным IP |
| 4 | Recovery Workflow | ✅ | Workflow не содержит команд удаления EIP |
| 5 | AWS State | ✅ | EIP существует и привязан к инстансу |
| 6 | Доступность | ✅ | Все сервисы отвечают по 52.59.86.193 |

---

## 🛡️ Внесённые изменения (для справки)

### Файл: `terraform/main.tf`

**Добавлено** в ресурс `aws_eip.app_eip`:
```hcl
lifecycle {
  prevent_destroy = true
  ignore_changes = [
    instance,
    network_interface,
    associate_with_private_ip
  ]
}
```

### Файл: `.github/workflows/infrastructure-recovery.yml`

**Заменено** удаление EIP на сохранение:
```yaml
# БЫЛО:
# echo "=== Releasing Elastic IPs ==="
# aws ec2 release-address --allocation-id $ALLOC_ID

# СТАЛО:
echo "=== Keeping Elastic IP untouched (persistent IP mode) ==="
```

### Файл: `docs/AWS_DEPLOYMENT_RU.md`

Обновлён раздел о Elastic IP с пометкой о постоянном IP.
