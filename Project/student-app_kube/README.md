# Student Management App - 3-Tier Kubernetes Deployment

This is a layered 3-tier architecture deployment of the Student Management application on Kubernetes (minikube).

## Architecture

- **Nginx Layer** (`nginx/`): Frontend reverse proxy
- **App Layer** (`app/`): Flask Python application
- **Database Layer** (`database/`): MySQL database

## Kubernetes Manifests

Located in `k8s/` directory:
- `01-mysql-deployment.yaml`: MySQL database deployment with persistent storage
- `02-mysql-init-configmap.yaml`: Database initialization script
- `03-app-deployment.yaml`: Flask app deployment (2 replicas)
- `04-nginx-deployment.yaml`: Nginx reverse proxy deployment
- `05-mysql-service.yaml`: MySQL ClusterIP service
- `06-app-service.yaml`: App ClusterIP service
- `07-nginx-service.yaml`: Nginx NodePort service (port 30080)

## Prerequisites

- minikube installed and running
- kubectl installed
- Docker installed (for building images)

## Deployment Steps

### 1. Start minikube
```bash
minikube start
eval $(minikube docker-env)
```

### 2. Build Docker images (with minikube docker environment)
```bash
cd nginx
docker build -t student-nginx:latest .
cd ../app
docker build -t student-app:latest .
cd ../database
docker build -t student-db:latest .
cd ..
```

### 3. Deploy to Kubernetes
```bash
# Create ConfigMaps and apply manifests in order
kubectl apply -f k8s/02-mysql-init-configmap.yaml
kubectl apply -f k8s/01-mysql-deployment.yaml
kubectl apply -f k8s/05-mysql-service.yaml
kubectl apply -f k8s/03-app-deployment.yaml
kubectl apply -f k8s/06-app-service.yaml
kubectl apply -f k8s/04-nginx-deployment.yaml
kubectl apply -f k8s/07-nginx-service.yaml
```

Or apply all at once:
```bash
kubectl apply -f k8s/
```

### 4. Check deployment status
```bash
kubectl get pods -w
kubectl get svc
kubectl get deployments
```

### 5. Access the application

#### Via NodePort (Nginx):
```bash
minikube ip
# Open browser to http://<minikube-ip>:30080
```

Or use minikube service command:
```bash
minikube service nginx-service
```

#### Logs and Debugging:
```bash
# Check pod logs
kubectl logs -f deployment/app-deployment
kubectl logs -f deployment/mysql-deployment
kubectl logs -f deployment/nginx-deployment

# Connect to MySQL
kubectl exec -it <mysql-pod-name> -- mysql -u root -p

# Describe pods for events
kubectl describe pod <pod-name>
```

## Cleanup

```bash
kubectl delete -f k8s/
```

## Features

- **3-Tier Architecture**: Properly separated layers
- **Persistent Storage**: MySQL uses PersistentVolumeClaim
- **Health Checks**: Liveness and readiness probes configured
- **Scalability**: App deployment set to 2 replicas
- **Environment Configuration**: Uses ConfigMaps and environment variables
- **Load Balancing**: Nginx proxies requests to app service
- **Resource Limits**: Memory and CPU limits defined for all containers
