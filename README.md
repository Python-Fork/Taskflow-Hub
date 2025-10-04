# TaskFlow Hub

**TaskFlow Hub** — минимальный оркестратор задач с Python и Go-воркерами.  
Цель: от простого MVP («создать задачу → выполнить воркером → получить результат») до полнофункционального SaaS.  

Репозиторий развивается по [ROADMAP.md](./ROADMAP.md).

---

## 🚀 Быстрый старт

### 1. Клонирование и подготовка
```bash
git clone https://github.com/Python-Fork/Taskflow-Hub.git
cd taskflow-hub
cp .env.example .env
```

### 2. Сборка и запуск через Docker
```bash
docker compose up -d --build
```
> Команда соберёт образы и поднимет сервисы в фоне. Для остановки используйте `docker compose down`.

### 3. Проверка
```bash
docker compose ps
curl http://localhost:8000/health
```
> Endpoint `/health` должен вернуть статус 200. Дополнительно можно запустить `make test` для проверки автотестов.
