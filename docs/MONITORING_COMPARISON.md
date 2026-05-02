# Мониторинг: Локальная машина vs AWS

## 📊 Сравнительная таблица метрик

| Метрика | Локально (Mac) | Production (AWS) | Описание |
|---------|----------------|------------------|----------|
| **Окружение** | MacBook (Docker Desktop) | AWS EC2 + ECS/EKS | Платформа развертывания |
| **Prometheus URL** | `http://localhost:9090` | `http://<AWS_IP>:9090` или Load Balancer | Адрес веб-интерфейса Prometheus |
| **Grafana URL** | `http://localhost:3000` | `http://<AWS_IP>:3000` или Load Balancer | Адрес дашбордов Grafana |
| **Targets** | 2-3 контейнера (app, db) | 5-10+ контейнеров (app replicas, db, cache, etc.) | Количество наблюдаемых целей |
| **Scrape Interval** | 15-30 секунд | 15 секунд | Частота сбора метрик |
| **Data Retention** | 7 дней | 30+ дней | Хранение исторических данных |
| **Network** | localhost (bridge) | VPC с приватными подсетями | Сетевая архитектура |
| **CPU Usage** | 5-15% (idle) | 30-70% (под нагрузкой) | Утилизация процессора |
| **Memory Usage** | 200-500 MB | 1-4 GB | Потребление памяти |
| **Request Rate** | 0.1-1 req/s (тесты) | 10-100+ req/s (реальные пользователи) | Частота запросов |
| **Alert Rules** | Минимальные (для тестов) | Production-ready (CPU, Memory, Disk, Availability) | Настройка алертов |
| **Storage** | Локальный диск | EBS Volume (persistent) | Хранилище данных |
| **Security** | Без аутентификации | BasicAuth/OAuth + Security Groups | Безопасность доступа |

---

## 🔍 Что показывает Prometheus

### 📍 Локальное окружение (Mac)
Prometheus на локальной машине собирает:

1. **Базовые метрики контейнеров:**
   - `container_cpu_usage_seconds_total` - CPU время контейнеров
   - `container_memory_usage_bytes` - Использование памяти
   - `container_network_receive_bytes_total` - Входящий трафик
   - `container_network_transmit_bytes_total` - Исходящий трафик

2. **Метрики приложения (Flask):**
   - `flask_http_request_duration_seconds` - Время обработки HTTP запросов
   - `flask_http_request_total` - Общее количество запросов
   - `flask_http_request_exceptions_total` - Количество ошибок
   - `up{job="flask-app"}` - Статус доступности приложения (1 = работает, 0 = недоступно)

3. **Метрики базы данных:**
   - `postgres_up` - Доступность PostgreSQL
   - `postgres_connections` - Количество активных соединений

**Особенности локальных метрик:**
- ✅ Стабильные значения (минимальная нагрузка)
- ✅ Легко воспроизводимые тесты
- ⚠️ Не отражают реальное поведение под нагрузкой
- ⚠️ Отсутствуют сетевые задержки как в реальной сети

---

### ☁️ Production окружение (AWS)
Prometheus в AWS собирает те же метрики, но с другими характеристиками:

1. **Расширенные метрики контейнеров:**
   - Множество реплик приложения (масштабирование)
   - Метрики Load Balancer (ELB/ALB)
   - Auto-scaling метрики

2. **Метрики приложения с реальной нагрузкой:**
   - `flask_http_request_duration_seconds` показывает **реальные задержки** от пользователей
   - `flask_http_request_total` показывает **реальный трафик** (пики в часы пик)
   - Видны паттерны использования (дневные/ночные часы, выходные)

3. **Дополнительные AWS метрики:**
   - `node_disk_io_time_seconds_total` - I/O дисков EBS
   - `node_network_receive_bytes_total` - Реальный сетевой трафик
   - CloudWatch метрики (интеграция)

**Особенности production метрик:**
- 📈 Динамические и непредсказуемые значения
- 📈 Реальные паттерны использования
- 📈 Аномалии и пиковые нагрузки
- 📈 Сетевые задержки между сервисами

---

## 🧪 Как проверить метрики

### Локально (Mac)

```bash
# 1. Проверить доступность Prometheus
curl http://localhost:9090/-/healthy

# 2. Посмотреть все цели мониторинга
curl http://localhost:9090/api/v1/targets | jq

# 3. Запросить конкретную метрику - CPU usage
curl -s 'http://localhost:9090/api/v1/query?query=rate(container_cpu_usage_seconds_total[1m])' | jq

# 4. Запросить метрику - Memory usage
curl -s 'http://localhost:9090/api/v1/query?query=container_memory_usage_bytes' | jq

# 5. Проверить время ответа Flask приложения
curl -s 'http://localhost:9090/api/v1/query?query=flask_http_request_duration_seconds_sum' | jq

# 6. Проверить статус приложения (availability)
curl -s 'http://localhost:9090/api/v1/query?query=up{job="flask-app"}' | jq

# 7. Посмотреть количество запросов за последние 5 минут
curl -s 'http://localhost:9090/api/v1/query?query=rate(flask_http_request_total[5m])' | jq

# 8. Открыть Grafana дашборд
open http://localhost:3000
```

---

### Production (AWS)

```bash
# Замените <AWS_IP> на реальный IP адрес или DNS вашего EC2 инстанса
AWS_IP="your-ec2-instance.amazonaws.com"

# 1. Проверить доступность Prometheus (может требовать VPN/Bastion)
curl http://${AWS_IP}:9090/-/healthy

# 2. Посмотреть все цели мониторинга
curl http://${AWS_IP}:9090/api/v1/targets | jq

# 3. Запросить CPU usage всех контейнеров
curl -s "http://${AWS_IP}:9090/api/v1/query?query=rate(container_cpu_usage_seconds_total[1m])" | jq

# 4. Запросить Memory usage
curl -s "http://${AWS_IP}:9090/api/v1/query?query=container_memory_usage_bytes" | jq

# 5. Проверить время ответа Flask (P95 latency)
curl -s "http://${AWS_IP}:9090/api/v1/query?query=histogram_quantile(0.95, flask_http_request_duration_seconds_bucket)" | jq

# 6. Проверить availability всех реплик
curl -s "http://${AWS_IP}:9090/api/v1/query?query=up" | jq

# 7. Посмотреть RPS (requests per second) за последние 5 минут
curl -s "http://${AWS_IP}:9090/api/v1/query?query=rate(flask_http_request_total[5m])" | jq

# 8. Проверить количество активных реплик
curl -s "http://${AWS_IP}:9090/api/v1/query?query=count(up{job='flask-app'}==1)" | jq

# Альтернатива: через SSH туннель (если Prometheus за firewall)
ssh -L 9090:localhost:9090 ec2-user@${AWS_IP}
# Затем локально: curl http://localhost:9090/api/v1/targets
```

---

## 🎓 Для защиты проекта

### Что говорить на презентации:

1. **О разнице окружений:**
   > "Я настроил идентичный стек мониторинга локально и в AWS. Локально я использую Docker Desktop для разработки и тестирования, а в production на AWS разворачиваю тот же стек, но с расширенной конфигурацией для высокой доступности."

2. **О метриках:**
   > "Prometheus собирает ключевые метрики: CPU, память, время ответа приложения и availability. Локально я вижу стабильные значения при тестировании, а в AWS метрики отражают реальное поведение под нагрузкой от пользователей."

3. **О практической пользе:**
   > "На локальной машине я использую метрики для отладки и оптимизации кода. В production те же метрики помогают отслеживать производительность, настраивать алерты и принимать решения об масштабировании."

4. **О конкретных примерах:**
   > "Например, метрика `flask_http_request_duration_seconds` локально показывает ~50ms, потому что нет сетевых задержек. В AWS она может быть ~200-300ms из-за реального интернет-трафика, что помогает оптимизировать приложение."

5. **О масштабируемости:**
   > "Локально у меня 1-2 контейнера, в AWS я могу масштабировать до 10+ реплик в зависимости от нагрузки. Prometheus автоматически обнаруживает новые targets через service discovery."

6. **О будущих улучшениях:**
   > "В дальнейшем планирую добавить AlertManager для уведомлений, интеграцию с PagerDuty и distributed tracing с Jaeger."

---

## 🏗️ Визуальная диаграмма архитектуры мониторинга

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ЛОКАЛЬНОЕ ОКРУЖЕНИЕ (Mac)                            │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
    │  Developer   │────────▶│   Browser    │────────▶│     App      │
    │   (You)      │         │ localhost:5k │         │ (Flask:5000) │
    └──────────────┘         └──────────────┘         └──────┬───────┘
                                                              │
                                                              │ exposes /metrics
                                                              │
                             ┌────────────────────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Prometheus    │◀──── scrapes metrics every 15s
                    │  localhost:9090 │
                    └────────┬────────┘
                             │
                             │ stores time-series data
                             │
                             ▼
                    ┌─────────────────┐
                    │     Grafana     │◀──── visualizes dashboards
                    │  localhost:3000 │
                    └─────────────────┘

    [Docker Network: bridge]
    - 1x Flask App Container
    - 1x PostgreSQL Container  
    - 1x Prometheus Container
    - 1x Grafana Container

    Metrics характеристики:
    ✓ CPU: 5-15% (idle)
    ✓ Memory: 200-500 MB
    ✓ Requests: 0.1-1 req/s (manual tests)
    ✓ Latency: ~50ms (no network overhead)


┌─────────────────────────────────────────────────────────────────────────────┐
│                       PRODUCTION ОКРУЖЕНИЕ (AWS)                            │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐         ┌──────────────────┐         ┌─────────────────┐
    │    Users     │────────▶│  Load Balancer   │────────▶│   App Replica 1 │
    │  (Internet)  │         │   (ALB/ELB)      │         │   (Flask:5000)  │
    └──────────────┘         └────────┬─────────┘         └────────┬────────┘
                                      │                            │
                                      │                            │ /metrics
                                      │                            │
                                      ├───────────────┐            │
                                      │               │            │
                             ┌────────▼────┐  ┌───────▼──────┐    │
                             │ App Replica │  │ App Replica  │    │
                             │      2      │  │      3       │    │
                             │(Flask:5000) │  │(Flask:5000)  │    │
                             └─────────────┘  └──────────────┘    │
                                                                   │
                   ┌───────────────────────────────────────────────┘
                   │
                   ▼
          ┌─────────────────┐
          │   Prometheus    │◀──── service discovery (Consul/Kubernetes)
          │ <AWS_IP>:9090   │◀──── scrapes all replicas
          └────────┬────────┘
                   │
                   │ persists to EBS Volume (30 days)
                   │
                   ▼
          ┌─────────────────┐
          │     Grafana     │◀──── public dashboards
          │ <AWS_IP>:3000   │◀──── BasicAuth protected
          └─────────────────┘
                   │
                   │ alerting
                   ▼
          ┌─────────────────┐
          │  AlertManager   │──────▶ Slack/PagerDuty/Email
          │ <AWS_IP>:9093   │
          └─────────────────┘

    [AWS VPC Architecture]
    - 3x Flask App Containers (Auto-scaled)
    - 1x PostgreSQL RDS Instance
    - 1x Redis Cache (ElastiCache)
    - 1x Prometheus EC2/Container
    - 1x Grafana EC2/Container
    - 1x AlertManager Container

    Metrics характеристики:
    ✓ CPU: 30-70% (real user load)
    ✓ Memory: 1-4 GB
    ✓ Requests: 10-100+ req/s (real traffic)
    ✓ Latency: ~200-300ms (network overhead, DB queries)
    ✓ Peak hours: visible patterns (9am-6pm)


┌─────────────────────────────────────────────────────────────────────────────┐
│                          КЛЮЧЕВЫЕ РАЗЛИЧИЯ                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    Local (Mac)                          Production (AWS)
    ───────────────────────────────────────────────────────────────────────────
    Single instance                  →   Multiple replicas + load balancing
    Static metrics                   →   Dynamic, real-world patterns
    Developer testing only           →   Real user traffic
    No alerts                        →   Production-ready alerting
    7 days retention                 →   30+ days retention
    No authentication                →   Secured with auth + firewall
    localhost network                →   VPC with private/public subnets
    Instant response                 →   Real latency visible
```

---

## 📈 Примеры конкретных метрик

### 1. `container_cpu_usage_seconds_total`

**Локально (Mac):**
```promql
# PromQL Query
rate(container_cpu_usage_seconds_total{name="flask-app"}[1m])

# Результат:
0.023  # ~2.3% CPU usage (практически idle)
```

**Production (AWS):**
```promql
rate(container_cpu_usage_seconds_total{name=~"flask-app-.*"}[1m])

# Результат:
flask-app-1: 0.456  # ~45.6% CPU
flask-app-2: 0.523  # ~52.3% CPU
flask-app-3: 0.389  # ~38.9% CPU

# Видно распределение нагрузки между репликами
```

---

### 2. `container_memory_usage_bytes`

**Локально (Mac):**
```promql
container_memory_usage_bytes{name="flask-app"}

# Результат:
268435456  # 256 MB (стабильное значение)
```

**Production (AWS):**
```promql
container_memory_usage_bytes{name=~"flask-app-.*"}

# Результат:
flask-app-1: 1073741824   # 1 GB
flask-app-2: 1288490189   # 1.2 GB (утечка памяти?)
flask-app-3: 954728448    # 954 MB

# Видны различия - может указывать на проблемы
```

---

### 3. `flask_http_request_duration_seconds`

**Локально (Mac):**
```promql
histogram_quantile(0.95, 
  rate(flask_http_request_duration_seconds_bucket[5m])
)

# Результат (P95 latency):
0.052  # 52ms - быстро, нет сетевых задержек
```

**Production (AWS):**
```promql
histogram_quantile(0.95, 
  rate(flask_http_request_duration_seconds_bucket[5m])
)

# Результат (P95 latency):
0.287  # 287ms - реалистичное время с учетом:
       # - Сетевых задержек
       # - Запросов к базе данных
       # - Load balancer overhead
       # - Пиковых нагрузок
```

---

### 4. `up` (availability)

**Локально (Mac):**
```promql
up{job="flask-app"}

# Результат:
1  # Приложение работает (single instance)

# Время работы (uptime):
100%  # Всегда доступно, перезапускается только при деплое
```

**Production (AWS):**
```promql
up{job="flask-app"}

# Результат:
flask-app-1: 1  # UP
flask-app-2: 1  # UP
flask-app-3: 0  # DOWN (возможно, перезапуск или проблема)

# Общая доступность:
avg(up{job="flask-app"}) = 0.67  # 67% реплик онлайн

# С alerting правилом:
# ALERT: если avg(up) < 0.5 (меньше 50% реплик)
```

---

## 🔥 Почему Production метрики "интереснее"

### Локальные метрики (скучные, но полезные для разработки):
- ✅ Предсказуемые и стабильные
- ✅ Легко воспроизвести проблему
- ✅ Быстрая обратная связь при изменениях кода
- ⚠️ **НО:** Не показывают реальное поведение

**Пример локального сценария:**
```bash
# Разработчик делает 5 запросов руками:
curl http://localhost:5000/api/users
curl http://localhost:5000/api/users/1
curl http://localhost:5000/api/health

# Метрики покажут:
- Request rate: 0.1 req/s
- Latency: ~50ms (стабильно)
- CPU: 5-10%
- Memory: 256 MB (стабильно)
```

---

### Production метрики (интересные и реалистичные):

#### 1. **Реальные паттерны использования:**
```
00:00-06:00  →  10 req/s   (ночь, минимальный трафик)
09:00-12:00  →  150 req/s  (утренний пик - все открыли приложение)
12:00-14:00  →  200 req/s  (обеденный пик - максимальная активность)
18:00-20:00  →  120 req/s  (вечерний всплеск)
```

#### 2. **Аномалии и проблемы:**
```
- Внезапный spike: 500 req/s → приложение вирусится, новостная статья
- Медленные запросы: P95 latency 5 секунд → проблема с базой данных
- Memory leak: постепенный рост памяти 1GB → 3GB → 5GB → OOM crash
- Cascade failure: один сервис упал → цепная реакция
```

#### 3. **Географическое распределение:**
```
Latency by region:
- US-East:   100ms  (близко к серверу)
- Europe:    250ms  (трансатлантическая задержка)
- Asia:      450ms  (долгий путь)
```

#### 4. **Сезонность и тренды:**
```
- Будние дни vs выходные
- Время суток (люди спят/работают)
- Праздники (резкое падение трафика)
- Маркетинговые кампании (резкий рост)
```

---

## 🎯 Вывод

| Аспект | Локально | Production |
|--------|----------|------------|
| **Цель** | Разработка и отладка | Наблюдение за реальными пользователями |
| **Данные** | Синтетические тесты | Реальный трафик |
| **Ценность** | Быстрая итерация кода | Понимание реального использования |
| **Проблемы** | Баги и логические ошибки | Производительность, масштабирование, availability |
| **Действия** | Фикс кода и редеплой | Масштабирование, оптимизация, алертинг |

**Оба окружения критически важны:**
- **Локально** - разрабатываем и тестируем новые фичи
- **Production** - следим чтобы приложение работало хорошо для пользователей

**На защите проекта акцентируй:**
> "Я понимаю разницу между development и production окружениями. Локально я использую мониторинг для разработки, а в AWS те же инструменты работают в production для обеспечения надежности и производительности реального приложения."

---

## 📚 Дополнительные ресурсы

- **Prometheus Documentation:** https://prometheus.io/docs/
- **Grafana Dashboards:** https://grafana.com/grafana/dashboards/
- **PromQL Tutorial:** https://prometheus.io/docs/prometheus/latest/querying/basics/
- **Flask Metrics:** https://github.com/rycus86/prometheus_flask_exporter
- **AWS Monitoring Best Practices:** https://aws.amazon.com/architecture/well-architected/

---

*Последнее обновление: 28 апреля 2026*
