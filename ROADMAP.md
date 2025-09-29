# ROADMAP.md — TaskFlow Hub

## 1) Контекст и цель

**TaskFlow Hub** — мини-оркестратор задач: пользователи создают задания (парсинг, конвертация, нотификации, отчёты и т. п.), система распределяет их между воркерами (Python/Go), отслеживает статус, хранит результаты и метрики.
Цели:

* Прокачать **Python** как платформу бэкенда целиком (архитектура, async, потоки/процессы, SQL/NoSQL, тесты, CI/CD, деплой).
* Освоить **Go** и интеграцию Python+Go (микросервисы, gRPC/REST, высокопроизводительные воркеры).
* Публичный pet-проект с перспективой роста (вплоть до SaaS).

## 2) Архитектурный эскиз

* **API Gateway**: REST (и позже gRPC) для создания/чтения задач, статусов, результатов.
* **Broker**: очередь (Redis Streams / RabbitMQ / Kafka) для маршрутизации заданий.
* **Workers**:

  * Python-воркеры: I/O-heavy (парсинг, интеграции, вебхуки), а также async-пайплайны.
  * Go-воркеры: CPU-heavy (конвертация медиа/архивация/хеширование).
* **Хранилища**:

  * **Postgres** (основные сущности: пользователи, задачи, аудит/история).
  * **MongoDB** (большие/гибкие результаты, логи задач).
  * **Redis** (кеш/брокер/rate-limit).
* **Observability**: Prometheus + Grafana, структурное логирование, трейсинг.
* **UI**: простой веб-дашборд (позже).
* **CLI**: клиент на Go и/или на Python.
* **Инфра**: Docker Compose → Kubernetes (позже), GitHub Actions.

## 3) Технологический стек

* **Python**: FastAPI, asyncio, SQLAlchemy, Pydantic, pytest, Poetry/uv, logging/structlog, httpx, celery/aiokafka/redis-py (по выбору).
* **Go**: net/http или Gin/Fiber, goroutines/channels, gRPC (protobuf), zap/logrus, cobra для CLI.
* **Broker**: Redis Streams (MVP) → опционально Kafka/RabbitMQ.
* **DB**: Postgres + SQLAlchemy; MongoDB + pymongo; Redis.
* **Metrics**: Prometheus client (py + go), Grafana.
* **CI/CD**: GitHub Actions, Docker, docker-compose, позже Helm/ArgoCD (опционально).

## 4) Модель данных (черновик)

* **User**(id, email, hashed_password, role, tokens, created_at)
* **Task**(id, user_id, type, payload(json), status, priority, created_at, started_at, finished_at, result_ref, error)
* **Result**(id, task_id, storage(“mongo”|“s3”), ref, preview, size, ttl)
* **Event/Audit**(id, entity, entity_id, action, meta, ts)

## 5) Майлстоуны и задачи (создавай GitHub Issues по списку)

### Milestone 1 — MVP ядро (API + очередь + один воркер Python)

**Цель:** завести базовый цикл «создал задачу → выполнилась → получил результат».

1. **Init репозитория и инструменты**

   * Title: `chore: init repo, tooling`
   * Labels: `chore`, `infra`
   * Desc: Инициализировать репо, LICENSE, CODEOWNERS, README, Poetry/uv, .editorconfig, pre-commit, линтер/форматтер (ruff/black), basic Makefile.

2. **Скелет FastAPI + health**

   * Labels: `backend`, `python`, `api`
   * Desc: Приложение FastAPI, `/healthz`, конфиги через pydantic-settings, структурные логи.

3. **Postgres + SQLAlchemy (миграции)**

   * Labels: `backend`, `db`
   * Desc: Подключить Postgres, alembic миграции, таблицы `users`, `tasks`.

4. **Redis как брокер (Streams)**

   * Labels: `backend`, `broker`
   * Desc: Настроить Redis Streams, топики `tasks:created`, `tasks:results`.

5. **Создание задач (REST)**

   * Labels: `backend`, `api`
   * Desc: `POST /tasks` — создать задачу, положить в Redis Stream; `GET /tasks/{id}` — статус; `GET /tasks?user=...` — список.

6. **Python-воркер (async)**

   * Labels: `worker`, `python`
   * Desc: Воркер берёт из `tasks:created`, выполняет «демо-задачу» (скачать страницу и вытащить `<title>`), пишет результат.

7. **MongoDB для результатов/логов**

   * Labels: `backend`, `db`
   * Desc: Коллекции `results`, `task_logs`; хранить результаты демо-задачи и простые логи.

8. **Статусы/ошибки/ретраи**

   * Labels: `backend`
   * Desc: Task lifecycle: `queued → running → success|failed`, поля times, error, retry_count; стратегия ретраев.

9. **Docker Compose (локально)**

   * Labels: `infra`
   * Desc: docker-compose для api, worker, postgres, redis, mongo.

10. **Pytests (юнит + интеграционные)**

    * Labels: `testing`
    * Desc: Тесты на модели, ендпоинты, воркер; coverage badge.

11. **GitHub Actions CI**

    * Labels: `ci`
    * Desc: Линт/тесты/сборка образов.

**Критерий готовности Milestone 1:** создаём задачу → воркер выполняет → `GET /tasks/{id}` показывает `success` и ссылку/реф на результат в Mongo.

---

### Milestone 2 — Go-воркер и высокопроизводительные задачи

**Цель:** ввести Go и смешанный пул воркеров (Python+Go).

12. **Go-модуль: каркас воркера**

    * Labels: `worker`, `go`
    * Desc: Подключение к Redis Streams, конфиг, логирование.

13. **Go-задача (CPU-heavy)**

    * Labels: `worker`, `go`
    * Desc: Реализовать задачу «сжатие изображения» или «генерация хеша большого файла». Сохранить результат/метаданные.

14. **Роутинг по типам задач**

    * Labels: `backend`
    * Desc: Ввод `task.type` (e.g. `web_scrape`, `img_compress`), роутинг: Python-воркер обрабатывает I/O-heavy, Go — CPU-heavy.

15. **Общий формат сообщений**

    * Labels: `backend`, `protocol`
    * Desc: Согласовать JSON-схему payload/result, версионирование схем.

16. **gRPC (пилот)**

    * Labels: `go`, `protocol`
    * Desc: Проба gRPC между API-шлюзом и Go-сервисом (или отдельным контроллером), protobuf-контракты.

---

### Milestone 3 — Авторизация, роли, квоты

**Цель:** превратить прототип в многофункциональный сервис для нескольких пользователей.

17. **Auth: JWT/Session**

    * Labels: `security`, `backend`
    * Desc: Регистрация/логин, refresh-токены, роли `user`, `admin`.

18. **Квоты и приоритеты**

    * Labels: `backend`
    * Desc: Ограничения по количеству/скорости задач; приоритет в очереди.

19. **Rate-limit и защита API**

    * Labels: `security`
    * Desc: Rate-limit (Redis), базовые защиты (CORS, headers).

20. **Аудит событий**

    * Labels: `backend`, `db`
    * Desc: Таблица/коллекция аудита, запись ключевых событий.

---

### Milestone 4 — Observability и UX

**Цель:** наблюдаемость и удобство.

21. **Метрики (Prometheus)**

    * Labels: `observability`
    * Desc: Счётчики задач, latency, ретраи, ошибки; экспортеры py+go.

22. **Трейсинг (опционально)**

    * Labels: `observability`
    * Desc: OpenTelemetry трассы для API→Broker→Worker.

23. **Дашборд (веб)**

    * Labels: `frontend`, `ux`
    * Desc: Мини-UI: список задач, фильтры/статусы, карточка результата, SSE/WebSocket live-обновления.

24. **CLI-клиент (Go)**

    * Labels: `cli`, `go`
    * Desc: Команды: `login`, `task submit`, `task get`, `task logs`.

---

### Milestone 5 — Продвинутая оркестрация и деплой

**Цель:** развить возможности и подготовить к росту.

25. **Workflow (цепочки задач)**

    * Labels: `backend`, `orchestration`
    * Desc: Триггеры: `on_success`, `on_failure`, `fan-out`, `fan-in`, max_concurrency.

26. **Планировщик (cron-задачи)**

    * Labels: `backend`
    * Desc: Расписание задач, хранение cron, пропуски, задержки.

27. **Kubernetes (опционально)**

    * Labels: `infra`
    * Desc: Манифесты/Helm-чарты, раздельное масштабирование API/воркеров.

28. **SaaS-режим (опционально)**

    * Labels: `product`
    * Desc: Тарифы/лимиты/биллинг-заготовка, пользовательские webhooks.

---

## 6) Метки (Labels)

* `backend`, `worker`, `api`, `protocol`, `db`, `broker`
* `python`, `go`
* `infra`, `ci`, `security`, `observability`, `testing`
* `frontend`, `ux`, `cli`
* `orchestration`, `product`
* `chore`, `docs`

## 7) Гайд по созданию Issue (шаблон)

Копируй ниже как тело Issue:

```
### Цель
Коротко, что и зачем делаем.

### Результат
Критерии готовности (acceptance criteria).

### Технические заметки
- Архитектура/схема данных/контракты
- Гипотезы, риски, trade-offs

### Чеклист
- [ ] ...
- [ ] Тесты
- [ ] Логи/метрики
- [ ] Обновить документацию
```

## 8) Порядок работы

1. Создаём Milestone → добавляем туда задачи.
2. На каждую задачу — Issue по шаблону, с метками.
3. Ветки `feature/<issue-number>-<slug>`.
4. PR с чеклистом, CI должен проходить.
5. Документация: обновлять `README`/`/docs`.

## 9) Дорожная карта обучения по ходу проекта

* **M1:** FastAPI, Redis Streams, SQLAlchemy, Mongo, asyncio, pytest, Docker, Actions.
* **M2:** Go basics, goroutines, Redis Streams client (go), gRPC intro.
* **M3:** Auth/JWT, роли, rate-limit, безопасность API.
* **M4:** Prometheus/Grafana, структурные логи, WebSocket/SSE, CLI.
* **M5:** Workflow-движок, планировщик, K8s/Helm.

## 10) Идеи задач для демонстрации типов нагрузок

* I/O-heavy (Python): парсинг HTML, интеграция с внешними API, webhooks.
* CPU-heavy (Go): сжатие/хеширование больших файлов, мини-обработка изображений/видео.
* Микс: пайплайны «скачать → обработать → сохранить → уведомить».
