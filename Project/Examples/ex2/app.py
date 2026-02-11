import redis
from flask import Flask

try:
    app = Flask(__name__)
    
    # Connect to Redis
    try:
        redis_client = redis.Redis(host='redis', port=6379, decode_responses=True)
        redis_client.ping()
        print("Redis connected successfully")
    except redis.ConnectionError as e:
        print("Redis connection error: {}".format(e))
        redis_client = None
    
    @app.route('/')
    def hello():
        return "hello world"

except Exception as e:
    print("Error initializing app: {}".format(e))
    raise

if __name__ == '__main__':
    try:
        app.run(host='0.0.0.0', port=8000, debug=True)
    except Exception as e:
        print("Error running Flask app: {}".format(e))
