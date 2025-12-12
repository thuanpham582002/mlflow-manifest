FROM ghcr.io/mlflow/mlflow:latest

# Install required dependencies
RUN pip install --no-cache-dir psycopg2-binary boto3

# Set default MLflow server command
ENTRYPOINT ["mlflow"]
CMD ["server", "--host=0.0.0.0", "--port=5000"]