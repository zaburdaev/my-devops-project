# Минимальная конфигурация мониторинга (t3.micro)

## Зачем убрали Loki

На `t3.micro` (1 vCPU, 1 GB RAM) одновременный запуск `Flask + PostgreSQL + Redis + Nginx + Prometheus + Grafana + Loki` перегружает сервер.

Основные проблемы:
- высокий расход RAM и CPU;
- фризы Grafana;
- таймауты деплоя по SSH в GitHub Actions.

Поэтому Loki удалён из `docker-compose.yml` и из Grafana datasource provisioning.

## Что осталось в минимальном мониторинге

Оставлен только базовый стек:
- **Prometheus** — сбор метрик;
- **Grafana** — визуализация;
- простой дашборд с 2 статус-панелями:
  - `up{job="flask-app"}`
  - `up{job="prometheus"}`

## Снижение нагрузки Prometheus

Интервалы сбора увеличены:
- `scrape_interval: 60s`
- `evaluation_interval: 60s`

Это уменьшает частоту запросов и нагрузку на CPU/RAM.

## Memory limits контейнеров

Для ограничения потребления памяти настроены лимиты:
- `app`: `256m`
- `nginx`: `64m`
- `prometheus`: `128m`
- `grafana`: `128m`

Это снижает риск OOM и повышает стабильность на маленьком инстансе.

## Порядок запуска сервисов

Для более надёжного старта сервисы поднимаются поэтапно:
1. `postgres`, `redis`
2. `app`
3. `prometheus`, `grafana`, `nginx`

Такой подход добавлен и в CI/CD workflow, вместе с увеличенными таймаутами SSH-команды.

## Когда переходить на t3.small

Если даже после упрощения есть фризы/таймауты, обновите тип инстанса:

```hcl
resource "aws_instance" "health_dashboard" {
  instance_type = "t3.small"
}
```

Затем примените Terraform:

```bash
cd terraform
terraform apply -auto-approve
```

`t3.small` даёт больше ресурсов (2 vCPU, 2 GB RAM) и заметно стабильнее для мониторинга.
