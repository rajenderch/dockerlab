#!/bin/bash

echo "=== Student Management App - Kubernetes Deployment Script ==="
echo ""

# Check if minikube is running
echo "Checking minikube status..."
minikube status
if [ $? -ne 0 ]; then
    echo "Starting minikube..."
    minikube start
fi

echo ""
echo "Setting up Docker environment for minikube..."
eval $(minikube docker-env)

echo ""
echo "=== Building Docker images ==="
echo "Building nginx image..."
cd nginx
docker build -t student-nginx:latest .
if [ $? -ne 0 ]; then
    echo "Error building nginx image"
    exit 1
fi
cd ..

echo "Building app image..."
cd app
docker build -t student-app:latest .
if [ $? -ne 0 ]; then
    echo "Error building app image"
    exit 1
fi
cd ..

echo ""
echo "=== Deploying to Kubernetes ==="
echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/02-mysql-init-configmap.yaml
kubectl apply -f k8s/01-mysql-deployment.yaml
kubectl apply -f k8s/05-mysql-service.yaml
sleep 5
kubectl apply -f k8s/03-app-deployment.yaml
kubectl apply -f k8s/06-app-service.yaml
kubectl apply -f k8s/04-nginx-deployment.yaml
kubectl apply -f k8s/07-nginx-service.yaml

echo ""
echo "=== Waiting for pods to be ready ==="
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s
kubectl wait --for=condition=ready pod -l app=student-app --timeout=300s
kubectl wait --for=condition=ready pod -l app=nginx --timeout=300s

echo ""
echo "=== Deployment Status ==="
kubectl get pods
echo ""
kubectl get svc
echo ""
kubectl get deployments

echo ""
echo "=== Application Access ==="
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"
echo "Nginx Service NodePort: 30080"
echo "Access URL: http://$MINIKUBE_IP:30080"
echo ""
echo "To open in browser, run:"
echo "minikube service nginx-service"
