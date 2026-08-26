FROM python:3.11-slim

WORKDIR /app

# Copy requirements first for Docker layer caching
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app/ .

# Expose microservice port
EXPOSE 5000

# Non-root user for security best practices
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Use Gunicorn WSGI server bound to 0.0.0.0:5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
