import os
from flask import Flask, jsonify

app = Flask(__name__)

# Cloud provider environment variable detection
CLOUD_PROVIDER = os.getenv("CLOUD_PROVIDER", "Local Environment")
REGION = os.getenv("CLOUD_REGION", "localhost")

@app.route('/')
def home():
    return jsonify({
        "status": "online",
        "service": "multi-cloud-engine-api",
        "provider": CLOUD_PROVIDER,
        "region": REGION,
        "message": "Hello from Multi-Cloud Deployment Engine!"
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

    