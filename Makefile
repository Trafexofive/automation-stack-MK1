
# ======================================================================================
# ANSI
# ======================================================================================

RED     := \033[0;31m
GREEN   := \033[0;32m
YELLOW  := \033[1;33m
BLUE    := \033[0;34m
NC      := \033[0m

# ======================================================================================
# GENERAL CONFIGURATION
# ======================================================================================

SHELL := /bin/bash
COMPOSE_FILE ?= docker-compose.yml
COMPOSE := docker compose -f $(COMPOSE_FILE)

# ======================================================================================
# HELP & SELF-DOCUMENTATION
# ======================================================================================
.DEFAULT_GOAL := help

help:
	@echo -e "$(BLUE)========================================================================="
	@echo -e " Automation Stack MK1 - Master Makefile "
	@echo -e "=========================================================================$(NC)"
	@echo ""
	@echo -e "$(YELLOW)Usage: make [target] [service=SERVICE_NAME]$(NC)"
	@echo ""
	@echo -e "$(GREEN)Core Application Stack (docker-compose.yml):$(NC)"
	@echo -e "  up                  - Start core services. Automatically initializes DB if needed."
	@echo -e "  down                - Stop and remove core services."
	@echo -e "  logs [service=<name>] - Follow logs for core services."
	@echo -e "  ps                  - Show status of core services."
	@echo -e "  re                  - Rebuild and restart core services."
	@echo -e "  fclean              - Stop, remove, and delete volumes for the core stack."
	@echo ""
	@echo -e "$(GREEN)Utilities:$(NC)"
	@echo -e "  prune               - Prune all unused Docker resources (images, volumes, networks)."
	@echo -e "  ssh service=<name>  - Get a shell into a running container."
	@echo -e "$(BLUE)=========================================================================$(NC)"

# Phony targets to prevent conflicts with file names
.PHONY: app help up down logs ps build re clean fclean prune \        stop start ssh exec inspect

# ======================================================================================
# CORE APPLICATION STACK (docker-compose.yml)
# ======================================================================================

up: ## Start core services, ensuring DB is initialized
	@echo -e "$(GREEN)Starting core application stack...$(NC)"
	@$(COMPOSE) up -d --remove-orphans --wait

down: ## Stop and remove core services
	@echo -e "$(RED)Shutting down core application stack...$(NC)"
	@$(COMPOSE) down --remove-orphans

logs: ## Follow logs for core services
	@echo -e "$(BLUE)Tailing logs for core stack...$(NC)"
	@$(COMPOSE) logs -f --tail="100" $(service)

ps: ## Show status of core services
	@echo -e "$(BLUE)Status for core stack:$(NC)"
	@$(COMPOSE) ps

build: ## Build images for the core stack
	@$(COMPOSE) build $(service)

re: down build up ## Rebuild and restart core services

clean: down ## Alias for down

fclean: ## Remove containers, networks, and volumes for the core stack
	@echo -e "$(RED)Deep cleaning core stack (including volumes)...$(NC)"
	@$(COMPOSE) down --volumes --remove-orphans



# ======================================================================================
# UTILITIES
# ======================================================================================

ssh: ## Get an interactive shell into a running service container
	@if [ -z "$(service)" ]; then \
		echo -e "$(RED)Error: Service name required. Usage: make ssh service=<service_name>$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(GREEN)Establishing shell connection to $(service)...$(NC)"
	@$(COMPOSE) exec $(service) /bin/sh 2>/dev/null || \
	$(COMPOSE) exec $(service) /bin/bash

prune: ## Prune all unused Docker resources
	@echo -e "$(RED)Pruning all unused Docker resources...$(NC)"
	@docker system prune -af --volumes
	@docker builder prune -af
	@docker volume prune -af
	@echo -e "$(GREEN)Docker system prune complete.$(NC)"

# Forward any unknown target to the default docker-compose file
%:
	@$(COMPOSE) $@
