# Security Best Practices (my-devops-project)

## 1) Как менять пароли

### PostgreSQL
1. Сгенерировать новый сильный пароль (минимум 20 символов).
2. Обновить `POSTGRES_PASSWORD` в secret-хранилище (не в git).
3. Перезапустить сервисы контролируемо.
4. Проверить health-check и подключение приложения.

### Grafana
1. Установить `GF_SECURITY_ADMIN_USER` и `GF_SECURITY_ADMIN_PASSWORD` через env/secrets.
2. Не использовать `admin/admin`.
3. После деплоя войти в Grafana и проверить доступ.
4. Включить MFA/SSO (если доступно) и ограничить публичный доступ.

### Flask SECRET_KEY
1. Сгенерировать криптостойкое значение (`python -c "import secrets; print(secrets.token_urlsafe(32))"`).
2. Хранить только в secret manager / CI secrets.
3. Не переиспользовать ключ между окружениями.

## 2) Как настроить HTTPS

### Вариант A: Nginx + Let's Encrypt
1. Назначить домен на сервер.
2. Открыть только `80` и `443` в SG.
3. Выпустить сертификат (`certbot --nginx -d your-domain`).
4. Включить редирект HTTP -> HTTPS.
5. Добавить HSTS после проверки стабильности.

### Вариант B: AWS ALB + ACM
1. Выпустить сертификат в ACM.
2. Подключить ALB с HTTPS listener (443).
3. Nginx/приложение оставить внутренним бэкендом.
4. Ограничить прямой доступ к внутренним портам.

## 3) Как ограничить SSH доступ

1. В Terraform установить:
   - `allowed_ssh_cidr = "YOUR_STATIC_IP/32"`
2. Убедиться, что порт 22 не открыт на `0.0.0.0/0`.
3. По возможности использовать SSM Session Manager вместо публичного SSH.
4. Отключить password auth на сервере, оставить только key-based auth.

## 4) Как ротировать credentials

Рекомендуемый регламент:
- Плановая ротация: каждые 60-90 дней.
- Внеплановая ротация: сразу после инцидента/подозрения на утечку.

Процедура:
1. Создать новый секрет.
2. Обновить secret manager / GitHub Secrets.
3. Деплойнуть изменения.
4. Проверить работоспособность.
5. Отозвать старый секрет.
6. Задокументировать дату/инициатора/область действия.

## 5) Как мониторить безопасность

1. В CI включить:
   - `pip-audit` на каждый PR
   - SAST/CodeQL (GitHub Advanced Security)
   - Secret scanning + push protection
2. В инфраструктуре:
   - CloudWatch/логирование попыток входа
   - алерты на anomalous traffic / brute force
3. В Docker/K8s:
   - регулярный image scan (Trivy/Grype)
   - обновление базовых образов
4. В GitHub:
   - branch protection rules
   - required checks before merge
   - Dependabot alerts/security updates

## 6) Минимальный secure baseline для проекта

- Публично открыты только `80/443`
- Grafana/Prometheus за auth и/или VPN/IP allowlist
- Нет hardcoded credentials в tracked файлах
- `.env` и ключи исключены из git
- Все критичные зависимости на поддерживаемых версиях
- Регулярный security audit (ежемесячно)
