# 🛟 Disaster Recovery Guide (RU)

> Проект: Health Dashboard (`my-devops-project`)

---

## 1) Что делать, если сервер удалён

Признаки:
- CI/CD падает с ошибкой SSH timeout
- `dial tcp <old_ip>:22: i/o timeout`
- старый EC2 отсутствует в AWS Console

Действия:
1. Пересоздать инфраструктуру через Terraform
2. Обновить GitHub Secrets новым IP/ключом
3. Повторно развернуть приложение
4. Перенастроить мониторинг
5. Проверить доступность всех сервисов

---

## 2) Пере-развёртывание инфраструктуры

```bash
export AWS_ACCESS_KEY_ID="<AWS_ACCESS_KEY_ID>"
export AWS_SECRET_ACCESS_KEY="<AWS_SECRET_ACCESS_KEY>"
export AWS_DEFAULT_REGION="eu-central-1"

cd /home/ubuntu/my-devops-project/terraform
terraform state list
terraform destroy -auto-approve || true
terraform init
terraform plan
terraform apply -auto-approve
```

Получить данные:

```bash
terraform output -raw instance_public_ip
terraform output -raw ssh_private_key > my-devops-key.pem
chmod 600 my-devops-key.pem
```

---

## 3) Восстановление приложения

### Вариант A (рекомендуется): Ansible

```bash
cd /home/ubuntu/my-devops-project/ansible
# обновите inventory.ini новым IP
ansible-playbook -i inventory.ini playbook.yml
```

### Вариант B: вручную через SSH

```bash
ssh -i /home/ubuntu/my-devops-project/terraform/my-devops-key.pem ec2-user@<NEW_IP>
sudo dnf install -y git docker-buildx-plugin docker-compose-plugin || true
sudo mkdir -p /opt
cd /opt
sudo git clone https://github.com/zaburdaev/my-devops-project.git health-dashboard
sudo chown -R ec2-user:ec2-user /opt/health-dashboard
cd /opt/health-dashboard
cp .env.example .env
docker compose up -d --build
```

---

## 4) Повторная настройка мониторинга

```bash
cd /home/ubuntu/my-devops-project
./scripts/configure_grafana.sh <NEW_IP> admin admin
```

Проверки:
- Grafana: `http://<NEW_IP>:3000`
- Prometheus: `http://<NEW_IP>:9090`
- App health: `http://<NEW_IP>/health`

---

## 5) Обновление GitHub Secrets

Обязательно обновить:
- `SERVER_HOST` = `<NEW_IP>`
- `SERVER_USER` = `ec2-user`
- `SSH_PRIVATE_KEY` = содержимое нового `my-devops-key.pem`

После обновления выполните push в `main` для проверки CI/CD.

---

## 6) Recovery Checklist

- [ ] Terraform apply выполнен успешно
- [ ] Получены новый IP и SSH ключ
- [ ] GitHub Secrets обновлены
- [ ] Приложение отвечает на `/health`
- [ ] Prometheus в статусе Ready
- [ ] Grafana открывается и datasource подключены
- [ ] Дашборд показывает CPU/Memory/Request rate/Latency/Container health
- [ ] CI/CD deploy job проходит без SSH timeout
