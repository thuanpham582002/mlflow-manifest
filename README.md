# MLflow Kubernetes Deployment

This repository contains a Helm chart for deploying MLflow on Kubernetes.

## TLDR

```bash
# Option 1: Deploy with Helm Chart (Recommended)
helm install mlflow ./helm-mlflow

# Option 2: Deploy with Kubernetes manifests
kubectl apply -f manifests/

# Upgrade MLflow with interactive values
helm upgrade -i mlflow ./helm-mlflow
```

## About

This repository uses the [CETIC MLflow Helm Chart](https://github.com/cetic/helm-mlflow), a well-maintained Helm chart for deploying MLflow on Kubernetes.

### Features

- MLflow tracking server
- PostgreSQL/MySQL database backend support
- MinIO S3-compatible artifact storage
- Configurable service types (NodePort, LoadBalancer, Ingress)
- Kubernetes-native deployment

## Installation

### Prerequisites

- Kubernetes cluster 1.10+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure

### Quick Install

```bash
# Clone this repository
git clone https://github.com/thuanpham582002/mlflow-manifest.git
cd mlflow-manifest

# Install MLflow
helm install mlflow ./helm-mlflow
```

### Configuration

The chart can be configured by editing the `./helm-mlflow/values.yaml` file or using `--set` flags:

```bash
# Example with custom database configuration
helm install mlflow ./helm-mlflow \
  --set db.default.enabled=true \
  --set db.type=postgresql \
  --set db.user=myuser \
  --set db.password=mypassword
```

### Option 2: Kubernetes Manifests

For direct deployment with `kubectl`, use the manifests in the `manifests/` directory:

```bash
# Deploy with PostgreSQL first
kubectl apply -f manifests/postgresql-pvc.yaml
kubectl apply -f manifests/postgresql-service.yaml
kubectl apply -f manifests/postgresql-deployment.yaml

# Wait for PostgreSQL to be ready
kubectl wait --for=condition=ready pod -l app=postgresql -n mlflow --timeout=120s

# Deploy MLflow
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml
kubectl apply -f manifests/configmap.yaml
kubectl apply -f manifests/secrets.yaml

# Check deployment status
kubectl get pods -n mlflow
kubectl get svc -n mlflow

# Forward port to access MLflow
kubectl port-forward -n mlflow svc/mlflow-service 5000:5000
```

**Note**: Before deploying with manifests, update the following secrets with your actual values:
- `mlflow-secrets`: Database credentials
- `mlflow-minio-secrets`: MinIO/S3 credentials

**PostgreSQL Setup**: The manifests include a PostgreSQL deployment with:
- Database: `mlflow`
- User: `mlflow`
- Password: `password` (update as needed)
- Storage: 5Gi persistent volume

For detailed configuration options, see the [CETIC MLflow documentation](./helm-mlflow/README.md).

## Repository Structure

```
mlflow-manifest/
├── README.md                 # This file
├── Dockerfile               # Custom MLflow image with dependencies
├── manifests/               # Kubernetes manifests
│   ├── deployment.yaml      # MLflow deployment (exact match)
│   ├── configmap.yaml       # Configuration
│   ├── secrets.yaml         # Database and MinIO secrets
│   ├── service.yaml         # ClusterIP service
│   ├── namespace.yaml       # mlflow namespace
│   ├── postgresql-deployment.yaml  # PostgreSQL database
│   ├── postgresql-service.yaml     # PostgreSQL service
│   ├── postgresql-pvc.yaml         # PostgreSQL storage
│   └── postgresql-init.yaml        # Database initialization
└── helm-mlflow/             # MLflow Helm chart
    ├── Chart.yaml           # Chart metadata
    ├── values.yaml          # Default configuration values
    ├── templates/           # Kubernetes templates
    └── README.md           # Detailed chart documentation
```

## Support

For issues and questions related to the Helm chart itself, please refer to the [upstream repository](https://github.com/cetic/helm-mlflow).