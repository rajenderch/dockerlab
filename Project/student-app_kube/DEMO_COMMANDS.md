# COMMANDS TO SEE THE DEMO OUTPUT

## Quick Start - View Live Application

### Option 1: Open in Browser (Easiest)
```bash
minikube service nginx-service
```
This will automatically open your default browser to the application.

### Option 2: Direct URL Access
Get the Minikube IP and access via browser:
```bash
# Get the IP
minikube ip
# Output: 192.168.49.2

# Then open in browser:
http://192.168.49.2:30080
```

### Option 3: Port Forward (for localhost access)
```bash
kubectl port-forward svc/nginx-service 8080:80
# Then visit: http://localhost:8080
```

---

## Commands to See the Deployment Status

### 1. View All Running Pods
```bash
kubectl get pods
# Output shows: MySQL, Flask App (2 replicas), and Nginx pods
```

### 2. View All Services
```bash
kubectl get svc
# Shows the endpoints to access each service
```

### 3. View All Deployments
```bash
kubectl get deployments
# Shows 3 deployments: mysql-deployment, app-deployment, nginx-deployment
```

### 4. View Detailed Pod Information
```bash
kubectl describe pod <pod-name>
# Example: kubectl describe pod mysql-deployment-876c6fcd8-5phkm
```

### 5. View Persistent Storage
```bash
kubectl get pvc
# Shows MySQL persistent volume claim status
```

---

## Commands to Test the Application

### 1. Health Check
```bash
MINIKUBE_IP=$(minikube ip)
curl http://$MINIKUBE_IP:30080/health
# Response: {"database":"connected","status":"ok"}
```

### 2. Get Main Application Page
```bash
curl http://$MINIKUBE_IP:30080/
# Shows the HTML student management interface
```

### 3. View Students in Database (via HTTP)
```bash
curl http://$MINIKUBE_IP:30080/ | grep -E '<td>[0-9]|<td>[A-Z]'
# Shows all students with their IDs, names, and emails
```

### 4. Add a New Student (via curl)
```bash
curl -X POST http://$MINIKUBE_IP:30080/add \
  -d "name=Bob+Smith&email=bob@example.com"
```

### 5. Direct Database Access
```bash
# Get MySQL pod name
MYSQL_POD=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}')

# Connect to MySQL
kubectl exec -it $MYSQL_POD -- mysql -u root -prootpassword -e "SELECT * FROM studentdb.students;"

# Output shows all students with timestamps
```

---

## Commands to View Application Logs

### 1. View Flask App Logs
```bash
# Real-time logs
kubectl logs -f deployment/app-deployment

# Last 50 lines from both replicas
kubectl logs deployment/app-deployment --tail=50
```

### 2. View MySQL Logs
```bash
kubectl logs -f deployment/mysql-deployment
```

### 3. View Nginx Proxy Logs
```bash
kubectl logs -f deployment/nginx-deployment
```

### 4. Watch Logs from All Components
```bash
# Terminal 1
kubectl logs -f deployment/mysql-deployment

# Terminal 2
kubectl logs -f deployment/app-deployment

# Terminal 3
kubectl logs -f deployment/nginx-deployment
```

---

## Commands for Real-time Monitoring

### 1. Watch Pods as They Change
```bash
kubectl get pods -w
# Press Ctrl+C to stop
```

### 2. Watch Services
```bash
kubectl get svc -w
```

### 3. Get Events (for troubleshooting)
```bash
kubectl get events --sort-by='.lastTimestamp'
```

---

## Complete Demo Script

Run the included demo script to see everything:
```bash
bash demo.sh
```

This script shows:
- Deployment status
- Service endpoints
- Health checks
- Sample data from database
- Usage instructions
- Cleanup commands

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Client Browser                     │
└─────────────────────────────────────────────────────┘
                         │
                    (Port 30080)
                         │
         ┌───────────────────────────────┐
         │   Nginx (Reverse Proxy)       │
         │   NodePort Service            │
         │   nginx-deployment (1 replica)│
         └───────────────────────────────┘
                         │
              (Internal Service Port 5000)
                         │
         ┌───────────────────────────────┐
         │  Flask Application Layer      │
         │  app-service (ClusterIP)      │
         │  app-deployment (2 replicas)  │
         │  Port: 5000                   │
         └───────────────────────────────┘
                         │
              (Internal Service Port 3306)
                         │
         ┌───────────────────────────────┐
         │   MySQL Database Layer        │
         │   mysql-service (ClusterIP)   │
         │   mysql-deployment (1 replica)│
         │   Port: 3306                  │
         │   Storage: PersistentVolume   │
         └───────────────────────────────┘
```

---

## Key Features Demonstrated

✅ **3-Tier Architecture**: Nginx → Flask → MySQL
✅ **Load Balancing**: Nginx proxies to 2 Flask app replicas
✅ **Persistent Storage**: MySQL data persists in PersistentVolume
✅ **Health Checks**: Liveness and readiness probes configured
✅ **Service Discovery**: DNS-based service names
✅ **Resource Limits**: Memory and CPU limits set
✅ **Database Initialization**: Automatic schema and seed data
✅ **Environment Variables**: Configuration via ConfigMaps

---

## Troubleshooting Commands

### Check Pod Status
```bash
kubectl describe pod <pod-name>
```

### Check Events
```bash
kubectl describe node minikube
```

### SSH into Pod
```bash
kubectl exec -it <pod-name> -- /bin/bash
```

### Test Internal Connectivity
```bash
# From nginx pod to app service
kubectl exec nginx-deployment-<hash> -- curl http://app-service:5000/health

# From app pod to mysql service
kubectl exec app-deployment-<hash> -- curl http://mysql-service:3306
```

### Clear All and Restart
```bash
# Delete all resources
kubectl delete -f k8s/

# Verify cleanup
kubectl get all

# Redeploy
kubectl apply -f k8s/
```

---

## Summary

**Access the App:**
- Browser: `minikube service nginx-service`
- Direct: `http://<minikube-ip>:30080`

**View Logs:**
- `kubectl logs -f deployment/app-deployment`
- `kubectl logs -f deployment/nginx-deployment`
- `kubectl logs -f deployment/mysql-deployment`

**Test API:**
- `curl http://<minikube-ip>:30080/health`
- `curl http://<minikube-ip>:30080/`

**Database:**
- `kubectl exec -it <mysql-pod> -- mysql -u root -prootpassword`
