FROM python:3.11-slim

WORKDIR /app

# Copy application code
COPY . .

# Install minimal dependencies without system packages
RUN pip install --no-cache-dir -e . && \
    pip install --no-cache-dir uvicorn

# Expose the application port
EXPOSE 8080

# Command to run the application
CMD ["python", "-m", "uvicorn", "langconnect.server:APP", "--host", "0.0.0.0", "--port", "8080"]
