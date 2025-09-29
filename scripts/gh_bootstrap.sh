#!/usr/bin/env bash
set -euo pipefail

# Требуется gh: https://cli.github.com/

echo 'Creating labels...'
gh label create "backend" --force >/dev/null 2>&1 || true
gh label create "worker" --force >/dev/null 2>&1 || true
gh label create "api" --force >/dev/null 2>&1 || true
gh label create "protocol" --force >/dev/null 2>&1 || true
gh label create "db" --force >/dev/null 2>&1 || true
gh label create "broker" --force >/dev/null 2>&1 || true
gh label create "python" --force >/dev/null 2>&1 || true
gh label create "go" --force >/dev/null 2>&1 || true
gh label create "infra" --force >/dev/null 2>&1 || true
gh label create "ci" --force >/dev/null 2>&1 || true
gh label create "security" --force >/dev/null 2>&1 || true
gh label create "observability" --force >/dev/null 2>&1 || true
gh label create "testing" --force >/dev/null 2>&1 || true
gh label create "frontend" --force >/dev/null 2>&1 || true
gh label create "ux" --force >/dev/null 2>&1 || true
gh label create "cli" --force >/dev/null 2>&1 || true
gh label create "orchestration" --force >/dev/null 2>&1 || true
gh label create "product" --force >/dev/null 2>&1 || true
gh label create "chore" --force >/dev/null 2>&1 || true
gh label create "docs" --force >/dev/null 2>&1 || true
gh label create "enhancement" --force >/dev/null 2>&1 || true
gh label create "bug" --force >/dev/null 2>&1 || true

echo 'Creating milestones...'
gh milestone create "Milestone 1 — MVP ядро" --description "API+Queue+Python worker" || true
gh milestone create "Milestone 2 — Go воркеры" --description "Go worker + routing + gRPC pilot" || true
gh milestone create "Milestone 3 — Auth & Quotas" --description "JWT, roles, rate limit" || true
gh milestone create "Milestone 4 — Observability & UX" --description "Metrics, tracing, UI, CLI" || true
gh milestone create "Milestone 5 — Orchestration & Deploy" --description "Workflows, scheduler, K8s" || true

echo 'Creating M1 issues...'
gh issue create -t "chore: init repo, tooling" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "chore" -l "infra" || true
gh issue create -t "Скелет FastAPI + health" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "backend" -l "python" -l "api" || true
gh issue create -t "Postgres + SQLAlchemy (миграции)" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "backend" -l "db" || true
gh issue create -t "Redis как брокер (Streams)" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "backend" -l "broker" || true
gh issue create -t "Создание задач (REST)" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "backend" -l "api" || true
gh issue create -t "Python-воркер (async)" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "worker" -l "python" || true
gh issue create -t "MongoDB для результатов/логов" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "backend" -l "db" || true
gh issue create -t "Статусы/ошибки/ретраи" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "backend" || true
gh issue create -t "Docker Compose (локально)" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "infra" || true
gh issue create -t "Pytests (юнит + интеграционные)" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "testing" || true
gh issue create -t "GitHub Actions CI" -b "$(cat .github/ISSUE_TEMPLATE/task_body.md)" -m "Milestone 1 — MVP ядро" -l "ci" || true
