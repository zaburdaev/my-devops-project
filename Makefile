# =============================================================================
# Makefile for Health Dashboard
# Author: Vitalii Zaburdaiev | DevOpsUA6
# Usage: make <target>
# =============================================================================

.PHONY: help build up down restart logs test lint clean deploy

# Default target
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# --- Docker ---
build: ## Build Docker images
	docker-compose build

up: ## Start all services in detached mode
	docker-compose up -d

down: ## Stop and remove all services
	docker-compose down

restart: down up ## Restart all services

logs: ## Show logs from all services
	docker-compose logs -f

ps: ## Show running containers
	docker-compose ps

# --- Testing ---
test: ## Run unit tests with pytest
	pip install -r requirements.txt -q
	python -m pytest tests/ -v

test-docker: ## Run tests inside Docker
	docker-compose run --rm app python -m pytest tests/ -v

# --- Linting ---
lint: ## Run code linting (requires flake8)
	pip install flake8 -q
	flake8 app/ tests/ --max-line-length=120

# --- Cleanup ---
clean: ## Remove containers, volumes, and images
	docker-compose down -v --rmi local
	docker system prune -f

# --- Deployment ---
deploy: build up ## Build and deploy all services
	@echo "Deployment complete! Access the dashboard at http://localhost"

# --- Terraform ---
tf-init: ## Initialize Terraform
	cd terraform && terraform init

tf-plan: ## Run Terraform plan
	cd terraform && terraform plan

tf-apply: ## Apply Terraform configuration
	cd terraform && terraform apply

tf-destroy: ## Destroy Terraform resources
	cd terraform && terraform destroy

# --- Ansible ---
ansible-deploy: ## Run Ansible playbook
	cd ansible && ansible-playbook -i inventory.ini playbook.yml

# --- Kubernetes ---
k8s-deploy: ## Deploy to Kubernetes
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/secret.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml

k8s-delete: ## Delete Kubernetes resources
	kubectl delete -f k8s/service.yaml
	kubectl delete -f k8s/deployment.yaml
	kubectl delete -f k8s/secret.yaml
	kubectl delete -f k8s/configmap.yaml
	kubectl delete -f k8s/namespace.yaml

# --- Helm ---
helm-install: ## Install Helm chart
	helm install health-dashboard k8s/helm/health-dashboard

helm-uninstall: ## Uninstall Helm chart
	helm uninstall health-dashboard
