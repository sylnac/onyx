# Makefile for Onyx development environment
# Provides convenient shortcuts for common development tasks

.PHONY: help dev dev-build down logs shell test lint format clean

# Default target
help:
	@echo "Onyx Development Commands"
	@echo "========================="
	@echo ""
	@echo "  make dev          - Start all services in development mode"
	@echo "  make dev-build    - Rebuild and start all services"
	@echo "  make down         - Stop all services"
	@echo "  make logs         - Tail logs from all services"
	@echo "  make logs-api     - Tail logs from the API service"
	@echo "  make logs-web     - Tail logs from the web service"
	@echo "  make shell-api    - Open a shell in the API container"
	@echo "  make shell-web    - Open a shell in the web container"
	@echo "  make test         - Run all tests"
	@echo "  make lint         - Run linters"
	@echo "  make format       - Auto-format code"
	@echo "  make clean        - Remove containers, volumes, and caches"
	@echo ""

# Start development environment
dev:
	docker compose -f docker-compose.dev.yml up -d
	@echo "Services started. Access the app at http://localhost:3000"

# Rebuild images and start
dev-build:
	docker compose -f docker-compose.dev.yml up -d --build

# Stop all services
down:
	docker compose -f docker-compose.dev.yml down

# Tail all logs
logs:
	docker compose -f docker-compose.dev.yml logs -f

# Tail API logs
logs-api:
	docker compose -f docker-compose.dev.yml logs -f api_server

# Tail web logs
logs-web:
	docker compose -f docker-compose.dev.yml logs -f web_server

# Open shell in API container
shell-api:
	docker compose -f docker-compose.dev.yml exec api_server /bin/bash

# Open shell in web container
shell-web:
	docker compose -f docker-compose.dev.yml exec web_server /bin/sh

# Run backend tests
test-backend:
	docker compose -f docker-compose.dev.yml exec api_server pytest tests/ -v

# Run all tests
test: test-backend
	@echo "All tests completed."

# Run linters (backend)
lint:
	docker compose -f docker-compose.dev.yml exec api_server ruff check .
	docker compose -f docker-compose.dev.yml exec api_server mypy .

# Auto-format code
format:
	docker compose -f docker-compose.dev.yml exec api_server ruff format .
	docker compose -f docker-compose.dev.yml exec api_server ruff check --fix .

# Full cleanup: containers, volumes, local caches
clean:
	docker compose -f docker-compose.dev.yml down -v --remove-orphans
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .mypy_cache -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .ruff_cache -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
	@echo "Cleanup complete."

# Pull latest images
pull:
	docker compose -f docker-compose.dev.yml pull

# Show running service status
status:
	docker compose -f docker-compose.dev.yml ps
