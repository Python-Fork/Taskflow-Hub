import asyncio
import json
import os
import httpx
from redis.asyncio import Redis
from src.common.constants import TASKS_CREATED_STREAM, TASKS_RESULTS_STREAM

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")

async def process_task(task):
    url = task.get("payload", {}).get("url")
    if not url:
        return {"status": "failed", "error": "no url provided"}
    async with httpx.AsyncClient(follow_redirects=True, timeout=15) as client:
        r = await client.get(url)
        r.raise_for_status()
        text = r.text
    title = ""
    start = text.lower().find("<title>")
    end = text.lower().find("</title>")
    if start != -1 and end != -1 and end > start:
        title = text[start + 7:end].strip()
    return {"status": "success", "result": {"title": title, "length": len(text)}}

async def worker_loop():
    redis = Redis.from_url(REDIS_URL, decode_responses=True)
    group = "pyworkers"
    consumer = "consumer"

    try:
        await redis.xgroup_create(TASKS_CREATED_STREAM, group, id="0", mkstream=True)
    except Exception:
        pass

    while True:
        resp = await redis.xreadgroup(group, consumer, streams={TASKS_CREATED_STREAM: ">"}, count=1, block=5000)
        if not resp:
            continue
        _, entries = resp[0]
        for entry_id, data in entries:
            try:
                payload = json.loads(data.get("data", "{}"))
                result = await process_task(payload)
            except Exception as e:
                result = {"status": "failed", "error": str(e)}
            await redis.xadd(TASKS_RESULTS_STREAM, {"data": json.dumps({"task_id": payload.get("id"), **result})})
            await redis.xack(TASKS_CREATED_STREAM, group, entry_id)

if __name__ == "__main__":
    asyncio.run(worker_loop())
