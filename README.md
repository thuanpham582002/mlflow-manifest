# MLflow Backend Kubernetes Manifests

This repository contains Kubernetes manifests for deploying MLflow backend with PostgreSQL database and MinIO object storage.

## Architecture

The deployment includes:
- **MLflow Backend** - Main MLflow tracking server
- **PostgreSQL** - Database for MLflow metadata
- **MinIO** - Object storage for MLflow artifacts (existing)

## Components

### Namespace
- `mlflow` - Dedicated namespace for MLflow components

### Services
- **mlflow-service** (ClusterIP) - Internal access to MLflow API on port 5000

### Deployments
- **mlflow** - MLflow tracking server with database and MinIO integration

### Configuration
- **mlflow-config** - Configuration for backend database and MinIO storage
- **mlflow-secrets** - Database credentials
- **mlflow-minio-secrets** - MinIO access credentials

### Database Setup
- **postgresql-mlflow-setup** - Job to initialize PostgreSQL database

### RBAC
- **mlflow-secret-reader** - Role for reading secrets
- **mlflow-secret-reader-binding** - Role binding for MLflow pod

## Deployment

### Apply with Kustomize
```bash
# Deploy MLflow backend
kubectl apply -k .

# Check deployment status
kubectl get pods -n mlflow
kubectl get svc -n mlflow

# Check MLflow logs
kubectl logs -n mlflow deployment/mlflow -f
```

## Accessing MLflow

### Internal Access
- **MLflow API**: `mlflow-service.mlflow.svc.cluster.local:5000`

### External Access Options

Since only ClusterIP services are configured, use one of these methods:

1. **Port Forwarding** (recommended for temporary access):
```bash
kubectl port-forward -n mlflow svc/mlflow-service 5000:5000
# Access MLflow at http://localhost:5000
```

2. **LoadBalancer Service** (if your cluster supports it):
```bash
kubectl patch svc mlflow-service -n mlflow -p '{"spec":{"type":"LoadBalancer"}}'
```

3. **Ingress Controller** (manual setup):
Create your own Ingress resource to route traffic to the ClusterIP service

## Configuration

### Environment Variables
The MLflow deployment is configured with:

```yaml
BACKEND_STORE_URI: postgresql+psycopg2://mlflow:password@postgresql:5432/mlflow
DEFAULT_ARTIFACT_ROOT: s3://mlflow/
MLFLOW_S3_ENDPOINT_URL: http://minio-service.minio:9000
AWS_ACCESS_KEY_ID: <from-secret>
AWS_SECRET_ACCESS_KEY: <from-secret>
```

### Required Secrets
Update the following secrets before deployment:

1. **mlflow-secrets**:
   - `DATABASE_URL`: PostgreSQL connection string
   - `POSTGRES_USER`: Database username
   - `POSTGRES_PASSWORD`: Database password

2. **mlflow-minio-secrets**:
   - `MINIO_ACCESS_KEY`: MinIO access key
   - `MINIO_SECRET_KEY`: MinIO secret key

3. **pg-superuser**:
   - `POSTGRES_PASSWORD`: PostgreSQL superuser password

## Prerequisites

1. **PostgreSQL**: The manifests assume an existing PostgreSQL deployment
2. **MinIO**: The manifests assume an existing MinIO deployment in `minio` namespace

## Monitoring and Maintenance

### Health Checks
- MLflow service includes liveness and readiness probes
- Database connectivity is validated during startup

### Logs
```bash
# MLflow logs
kubectl logs -n mlflow deployment/mlflow -f

# Database setup job logs
kubectl logs -n mlflow job/postgresql-mlflow-setup -f
```

### Scaling
To scale MLflow horizontally, update the replica count in the deployment:
```bash
kubectl scale deployment mlflow --replicas=3 -n mlflow
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Verify PostgreSQL is running and accessible
   - Check database credentials in secrets
   - Verify network connectivity between namespaces

2. **MinIO Connection Failed**
   - Verify MinIO is running and accessible
   - Check MinIO credentials in secrets
   - Verify bucket exists and permissions are correct

3. **Pod Startup Issues**
   - Check pod events: `kubectl describe pod -n mlflow`
   - Check logs: `kubectl logs -n mlflow deployment/mlflow`

### Cleanup
```bash
# Remove MLflow deployment
kubectl delete -k .

# Remove namespace (only if empty)
kubectl delete namespace mlflow
```

## Notes

- This deployment uses only ClusterIP services for security
- No external exposure is configured by default
- PostgreSQL and MinIO should be deployed separately
- Database is automatically initialized on first deployment
- All secrets should be updated with production values before use