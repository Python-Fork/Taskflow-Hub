# TaskFlow Hub

Мини-оркестратор задач с Python и Go воркерами. Этот репозиторий следует дорожной карте из `ROADMAP.md`.

## Быстрый старт (локально, Docker Compose)

```bash
cp .env.example .env
docker compose up -d --build
docker compose logs -f api
# открыть http://localhost:8000/healthz
```
