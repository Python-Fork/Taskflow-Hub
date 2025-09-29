from starlette.testclient import TestClient
from src.api.main import app

def test_health():
    client = TestClient(app)
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
