from fastapi import FastAPI
from pydantic_settings import BaseSettings
import logging

class Settings(BaseSettings):
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    api_log_level: str = "info"

    class Config:
        env_prefix = "API_"
        case_sensitive = False

settings = Settings()

logging.basicConfig(level=getattr(logging, settings.api_log_level.upper(), logging.INFO))
logger = logging.getLogger("api")

app = FastAPI(title="TaskFlow Hub API", version="0.1.0")

@app.get("/healthz")
async def healthz():
    return {"status": "ok"}
