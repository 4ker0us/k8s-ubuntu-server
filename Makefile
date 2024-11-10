# Makefile
.PHONY: all install build deploy clean logs status restart help

# Variables
SHELL := /bin/bash
K8S_DIR := k8s
INSTALL_SCRIPT := install-k8s.sh
APP_NAME := hello-world

# Colores para output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

all: install build deploy status

# Instalación inicial del ambiente
install:
	@echo -e "$(CYAN)📦 Instalando ambiente K8s...$(NC)"
	@if [ -f $(INSTALL_SCRIPT) ]; then \
		chmod +x $(INSTALL_SCRIPT) && ./$(INSTALL_SCRIPT); \
	else \
		echo -e "$(RED)❌ Error: $(INSTALL_SCRIPT) no encontrado$(NC)"; \
		exit 1; \
	fi

# Construir imagen Docker
build:
	@echo -e "$(CYAN)🏗️  Construyendo imagen Docker...$(NC)"
	docker build -t $(APP_NAME):latest .

# Desplegar la aplicación
deploy:
	@echo -e "$(CYAN)🚀 Desplegando aplicación...$(NC)"
	@if [ -d $(K8S_DIR) ]; then \
		kubectl apply -f $(K8S_DIR)/; \
		echo -e "$(GREEN)✅ Despliegue completado$(NC)"; \
	else \
		echo -e "$(RED)❌ Error: Directorio $(K8S_DIR) no encontrado$(NC)"; \
		exit 1; \
	fi

# Limpiar todos los recursos
clean:
	@echo -e "$(YELLOW)🧹 Limpiando recursos...$(NC)"
	@kubectl delete -f $(K8S_DIR)/ || true
	@echo -e "$(GREEN)✅ Limpieza completada$(NC)"

# Ver logs de la aplicación
logs:
	@echo -e "$(CYAN)📋 Mostrando logs...$(NC)"
	@kubectl logs -l app=$(APP_NAME) --tail=100 -f

# Ver estado de los recursos
status:
	@echo -e "$(CYAN)📊 Estado del cluster:$(NC)"
	@echo -e "$(YELLOW)Nodos:$(NC)"
	@kubectl get nodes
	@echo -e "\n$(YELLOW)Pods:$(NC)"
	@kubectl get pods
	@echo -e "\n$(YELLOW)Servicios:$(NC)"
	@kubectl get services

# Reiniciar la aplicación
restart:
	@echo -e "$(CYAN)🔄 Reiniciando aplicación...$(NC)"
	@kubectl rollout restart deployment $(APP_NAME)
	@echo -e "$(GREEN)✅ Reinicio iniciado$(NC)"

# Mostrar ayuda
help:
	@echo -e "$(CYAN)📚 Comandos disponibles:$(NC)"
	@echo -e "$(GREEN)make all$(NC)        - Instalar ambiente, construir imagen y desplegar"
	@echo -e "$(GREEN)make install$(NC)    - Instalar ambiente K8s"
	@echo -e "$(GREEN)make build$(NC)      - Construir imagen Docker"
	@echo -e "$(GREEN)make deploy$(NC)     - Desplegar aplicación"
	@echo -e "$(GREEN)make clean$(NC)      - Eliminar todos los recursos"
	@echo -e "$(GREEN)make logs$(NC)       - Ver logs de la aplicación"
	@echo -e "$(GREEN)make status$(NC)     - Ver estado de los recursos"
	@echo -e "$(GREEN)make restart$(NC)    - Reiniciar la aplicación"
