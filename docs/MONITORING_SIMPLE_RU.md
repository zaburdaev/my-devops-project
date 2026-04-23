# MONITORING SIMPLE (RU)

## Цель
Сделать мониторинг на t3.micro стабильно рабочим даже при ограниченных ресурсах.

## Что упрощено
1. **Prometheus retention** уменьшен до `6h` (вместо долгого хранения), чтобы снизить RAM/диск.
2. **Скрейп и evaluation** увеличены до `30s`, чтобы снизить нагрузку.
3. **Grafana dashboard** упрощён:
   - убраны проблемные панели `gauge`/`timeseries`;
   - используются базовые `stat` и `graph` панели;
   - только ключевые метрики (`up`, CPU, Memory).
4. Добавлены лимиты памяти контейнеров:
   - Prometheus: `256m` (reservation `128m`)
   - Grafana: `256m` (reservation `128m`)
   - Loki: `128m` (reservation `64m`)

## Важный фикс
Исправлен путь монтирования Grafana provisioning и dashboards в `docker-compose.yml`:
- было: `./grafana/...`
- стало: `./monitoring/grafana/...`

Без этого Grafana могла не подхватывать datasource/dashboard при старте.

## Минимальный порядок перезапуска
```bash
cd /opt/health-dashboard
sudo docker compose down
sudo docker compose up -d postgres redis
sleep 10
sudo docker compose up -d app
sleep 10
sudo docker compose up -d prometheus loki grafana
sleep 10
sudo docker compose up -d nginx
```

## Проверка, что всё работает
```bash
# Flask метрики
curl http://localhost:5000/metrics

# Prometheus target status (flask-app должен быть UP)
curl http://localhost:9090/api/v1/targets

# Prometheus query
curl "http://localhost:9090/api/v1/query?query=up"

# Grafana datasource
curl -u admin:admin http://localhost:3000/api/datasources
```

## Ожидаемый результат
- Grafana открывается без ошибок загрузки панелей.
- В дашборде есть хотя бы 1–3 панели с реальными данными.
- Prometheus видит `flask-app` как `UP`.

## Trade-offs
- Меньше история в Prometheus (только последние 6 часов).
- Реже обновление метрик (каждые 30 секунд).
- Дашборд проще, но надёжнее для демо на малом инстансе.
