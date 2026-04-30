# Мониторинг системы: Prometheus + Grafana (для защиты курсового проекта)

## 1. Зачем нужен мониторинг в DevOps-проекте

Мониторинг отвечает на три ключевых вопроса:

1. **Сервис работает?** (доступность, health checks)
2. **Сервис работает быстро?** (latency, response time)
3. **Сервис выдерживает нагрузку?** (CPU, RAM, RPS, состояние контейнеров)

В моём проекте стек мониторинга построен на **Prometheus + Grafana**.

---

## 2. Архитектура мониторинга в проекте

### Компоненты

- **Flask-приложение** экспортирует метрики на endpoint `/metrics`.
- **Prometheus** регулярно опрашивает метрики (pull-модель) и хранит time-series данные.
- **Grafana** подключается к Prometheus как к datasource и визуализирует данные в виде дашбордов.

### Логика потока данных

1. Приложение генерирует метрики (счётчики, гистограммы, системные показатели).
2. Prometheus по расписанию делает scrape целевых endpoint’ов (`flask-app`, `prometheus`).
3. Grafana выполняет PromQL-запросы к Prometheus.
4. На панели отображаются графики для анализа производительности и стабильности.

---

## 3. Какие метрики реально доступны

По фактической проверке Prometheus:

- `flask_*` — **нет доступных метрик**
- `container_*` — **нет доступных метрик**
- Есть полезные метрики приложения и системы:
  - `app_request_total`
  - `app_request_latency_seconds_bucket`
  - `app_request_latency_seconds_count`
  - `app_request_latency_seconds_sum`
  - `system_cpu_usage_percent`
  - `system_memory_usage_percent`
  - `system_disk_usage_percent`

Также доступна инфраструктурная метрика `up{job="..."}` для проверки доступности целей.

---

## 4. Принципы построения дашборда

Создан отдельный рабочий дашборд (без `No Data`):

- Файл: `grafana/working-dashboard.json`
- Название: **Health Dashboard (Working Metrics)**
- UID: `health-dashboard-working`

### Что показывает дашборд

1. **Flask Target Status** — доступность приложения (`up{job="flask-app"}`)
2. **Prometheus Target Status** — доступность Prometheus (`up{job="prometheus"}`)
3. **CPU Usage (%)** — `system_cpu_usage_percent`
4. **Memory Usage (%)** — `system_memory_usage_percent`
5. **Disk Usage (%)** — `system_disk_usage_percent`
6. **Total Request Rate (req/s)** — `sum(rate(app_request_total[5m]))`
7. **Request Rate by Endpoint** — `sum by (endpoint) (rate(app_request_total[5m]))`
8. **HTTP Latency p95 (s)** — `histogram_quantile(0.95, sum by (le) (rate(app_request_latency_seconds_bucket[5m])))`
9. **HTTP Average Latency (s)** — `sum(rate(app_request_latency_seconds_sum[5m])) / sum(rate(app_request_latency_seconds_count[5m]))`

---

## 5. Почему именно такие панели важны на защите

### Для доступности

- `up`-метрики показывают, что цели действительно живы.
- Можно быстро доказать, что monitoring stack не «декоративный», а рабочий.

### Для производительности API

- RPS показывает интенсивность трафика.
- p95 latency показывает реальное качество сервиса под нагрузкой.
- Средняя latency нужна для общей картины и сравнения с p95.

### Для ресурсов

- CPU/RAM/Disk показывают запас по ресурсам.
- По трендам можно обосновать масштабирование и capacity planning.

---

## 6. Как Prometheus и Grafana работают вместе (объяснение простыми словами)

- **Prometheus** — «сборщик и база метрик».
- **Grafana** — «визуальная аналитика поверх метрик».

Аналогия:

- Prometheus = «термометры + журнал измерений»
- Grafana = «панель приборов автомобиля»

Без Prometheus Grafana неоткуда брать данные. Без Grafana Prometheus остаётся «сырыми цифрами» без удобной визуализации.

---

## 7. Что было сделано для появления «живых графиков»

Чтобы на дашборде были не пустые линии, а реальные значения, был сгенерирован тестовый трафик:

- отправлено **90 HTTP-запросов** к приложению (`/`, `/health`, `/api/system-info`, `/metrics`)

После этого на графиках появились:

- ненулевой `sum(rate(app_request_total[5m]))`
- значения latency (в т.ч. p95 через `app_request_latency_seconds_bucket`)
- обновление счётчиков `app_request_total` и временных рядов

---

## 8. Что сказать комиссии про ограничения и улучшения

### Текущее ограничение

- В текущем наборе метрик отсутствуют `flask_*` и `container_*`.

### Возможные улучшения

1. Добавить **cAdvisor** для полноценных `container_*` метрик (CPU/memory/network per container).
2. Добавить **Node Exporter** для системных метрик хоста на уровне ОС.
3. Настроить **Alertmanager** для алертов в Telegram/Slack/email.
4. Ввести SLO/SLA-панели (ошибки, latency budget, availability за период).

---

## 9. Вывод для защиты

В проекте реализован полноценный рабочий мониторинг:

- Метрики собираются автоматически Prometheus
- Grafana отображает реальные графики нагрузки и задержек
- Дашборд позволяет оперативно оценивать здоровье приложения и инфраструктуры

Это соответствует практикам production DevOps и демонстрирует контроль за качеством сервиса в реальном времени.
