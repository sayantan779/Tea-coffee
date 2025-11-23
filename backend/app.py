from flask import Flask, request
import redis
import os

app = Flask(__name__)
# Connect to Redis using an environment variable we will set later
r = redis.Redis(host=os.environ.get('REDIS_HOST', 'localhost'), port=6379)

@app.route('/vote', methods=['POST'])
def vote():
    beverage = request.form['beverage']
    r.incr(beverage) # Increment the count in Redis
    return f"Voted for {beverage}!"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)