FROM python:3.11-slim

WORKDIR /app
ENV PIP_NO_CACHE_DIR=1 PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

COPY pyproject.toml README.md /app/
RUN pip install --upgrade pip && pip install poetry && poetry config virtualenvs.create false && poetry install --only main

COPY src /app/src

EXPOSE 8000
CMD ["uvicorn", "src.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
