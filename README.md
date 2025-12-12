# MLflow Kubernetes Deployment

This repository contains a Helm chart for deploying MLflow on Kubernetes.

## TLDR

```bash
# Install MLflow
helm install mlflow ./helm-mlflow

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

For detailed configuration options, see the [CETIC MLflow documentation](./helm-mlflow/README.md).

## Repository Structure

```
mlflow-manifest/
├── README.md                 # This file
└── helm-mlflow/             # MLflow Helm chart
    ├── Chart.yaml           # Chart metadata
    ├── values.yaml          # Default configuration values
    ├── templates/           # Kubernetes templates
    └── README.md           # Detailed chart documentation
```

## Support

For issues and questions related to the Helm chart itself, please refer to the [upstream repository](https://github.com/cetic/helm-mlflow).