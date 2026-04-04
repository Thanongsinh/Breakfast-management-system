# Makefile for Rental Backend

.PHONY: help build run test clean docker-build docker-up docker-down docker-logs

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Development Commands
build: ## Build the application
	go build -o rental-backend .

run: ## Run the application
	go run main.go

test: ## Run tests
	go test -v ./...

clean: ## Clean build artifacts
	rm -f rental-backend rental-backend.exe

# Docker Commands
docker-build: ## Build Docker image
	docker build -t rental-backend:latest .

docker-up: ## Start all services with docker-compose
	docker-compose up -d

docker-down: ## Stop all services
	docker-compose down

docker-down-clean: ## Stop all services and remove volumes
	docker-compose down -v

docker-logs: ## View backend logs
	docker-compose logs -f backend

docker-ps: ## Show running containers
	docker-compose ps

docker-restart: ## Restart backend service
	docker-compose restart backend

# Database Commands
db-shell: ## Access PostgreSQL shell
	docker-compose exec postgres psql -U postgres -d rental_db

redis-cli: ## Access Redis CLI
	docker-compose exec redis redis-cli

# Full Stack Commands
up: ## Start backend and all dependencies
	docker-compose up -d
	@echo "Services started!"
	@echo "Backend API: http://localhost:8080"
	@echo "MinIO Console: http://localhost:9001"

down: ## Stop all services
	docker-compose down
	@echo "Services stopped!"

rebuild: ## Rebuild and restart backend
	docker-compose up -d --build backend
	@echo "Backend rebuilt and restarted!"

logs: ## View all service logs
	docker-compose logs -f

health: ## Check backend health
	@curl -s http://localhost:8080/health | jq .
