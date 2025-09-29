.PHONY: help install lint test up down logs fmt

help:
	@echo "make install   - install deps (poetry)"
	@echo "make lint      - run ruff, black --check, isort --check"
	@echo "make fmt       - run formatters"
	@echo "make test      - run pytest"
	@echo "make up        - docker compose up -d --build"
	@echo "make down      - docker compose down"
	@echo "make logs      - docker compose logs -f api worker_py"

install:
	poetry install

lint:
	ruff check src tests
	black --check src tests
	isort --check-only src tests

fmt:
	ruff check --fix src tests
	black src tests
	isort src tests

test:
	pytest -q

up:
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f api worker_py
