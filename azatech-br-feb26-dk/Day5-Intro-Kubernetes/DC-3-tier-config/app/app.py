import os
from flask import Flask, jsonify
import redis

app = Flask(__name__)

REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)

@app.get("/")
def hits():
    count = r.incr("hits")
    return jsonify(message="hello from python", hits=count)

@app.get("/healthz")
def health():
    try:
        r.ping()
        return jsonify(status="ok", redis="ok")
    except Exception as e:
        return jsonify(status="degraded", error=str(e)), 500

if __name__ == "__main__":
    # dev server (fine for lab)
    app.run(host="0.0.0.0", port=5000)
