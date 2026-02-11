# Quick Reference - How to See the Demo

## 🚀 View the Running Application

### **Option 1: Automatic Browser Opening (Recommended)**
```bash
minikube service nginx-service
```
**Result:** Browser automatically opens to `http://192.168.49.2:30080`

### **Option 2: Direct URL Access**
```bash
# Get the IP address
minikube ip
# Output: 192.168.49.2

# Then visit in browser:
# http://192.168.49.2:30080
```

### **Option 3: Port Forwarding**
```bash
kubectl port-forward svc/nginx-service 8080:80
# Then visit: http://localhost:8080
```

---

## 📊 View Deployment Status

### Check All Components
```bash
kubectl get pods
kubectl get svc
kubectl get deployments
```

### Expected Output
```
Pods:
- mysql-deployment-876c6fcd8-5phkm (MySQL database)
- app-deployment-dccb69659-2w9jt (Flask app - replica 1)
- app-deployment-dccb69659-mhxtb (Flask app - replica 2)
- nginx-deployment-7796748c5f-2jg2k (Nginx proxy)

Services:
- mysql-service: ClusterIP 10.108.204.255 (internal)
- app-service: ClusterIP 10.98.11.8 (internal)
- nginx-service: NodePort 10.106.128.211 port 30080
```

---

## 🧪 Test the Application

### Test 1: Health Check
```bash
curl http://192.168.49.2:30080/health
# Response: {"database":"connected","status":"ok"}
```

### Test 2: Get Main Page (HTML)
```bash
curl http://192.168.49.2:30080/
# Shows the student management form with existing students
```

### Test 3: Add a Student
```bash
curl -X POST http://192.168.49.2:30080/add \
  -d "name=Alice+Johnson&email=alice@test.com"
# Redirects back to main page with new student added
```

### Test 4: View Students (parse HTML)
```bash
curl -s http://192.168.49.2:30080/ | grep -E '<td>[0-9]|<td>[A-Z]'
# Shows all students in table format
```

---

## 📝 View Application Logs

### Flask App Logs (Shows requests)
```bash
kubectl logs -f deployment/app-deployment
# Shows HTTP requests and database operations
```

### MySQL Logs
```bash
kubectl logs -f deployment/mysql-deployment
# Shows database startup and initialization
```

### Nginx Logs
```bash
kubectl logs -f deployment/nginx-deployment
# Shows incoming requests and proxy operations
```

---

## 🗄️ Access Database Directly

### Get MySQL Pod Name
```bash
MYSQL_POD=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}')
echo $MYSQL_POD
```

### Connect to MySQL
```bash
kubectl exec -it $MYSQL_POD -- mysql -u root -prootpassword
```

### Query Students
```bash
# Inside MySQL shell:
USE studentdb;
SELECT * FROM students;
SELECT COUNT(*) FROM students;
```

---

## 🎯 Automated Demo Script

Run everything at once:
```bash
bash demo.sh
```

This shows:
- ✅ All pod status
- ✅ Service endpoints
- ✅ Health check
- ✅ Sample data from database
- ✅ Application access instructions

---

## 📁 Project Structure (What Was Created)

```
student-app_kube/
├── nginx/                    # Reverse proxy layer
│   ├── Dockerfile
│   └── default.conf         # Nginx config (routes to app-service:5000)
│
├── app/                      # Flask application layer
│   ├── Dockerfile
│   ├── app.py               # Flask app with /add, /delete, /health endpoints
│   ├── requirements.txt      # Python dependencies
│   └── templates/
│       └── index.html       # Bootstrap UI for student management
│
├── database/                 # MySQL database layer
│   ├── Dockerfile
│   └── init.sql             # Database schema + sample data
│
├── k8s/                      # Kubernetes manifests
│   ├── 01-mysql-deployment.yaml
│   ├── 02-mysql-init-configmap.yaml
│   ├── 03-app-deployment.yaml (2 replicas)
│   ├── 04-nginx-deployment.yaml
│   ├── 05-mysql-service.yaml
│   ├── 06-app-service.yaml
│   └── 07-nginx-service.yaml (NodePort 30080)
│
├── README.md                 # Full setup guide
├── DEMO_COMMANDS.md          # Complete list of demo commands
├── demo.sh                   # Automated demo script
└── deploy.sh                 # Automated deployment script
```

---

## 🏗️ Architecture Diagram

```
┌──────────────────┐
│   Your Browser   │
│ (Port 30080)     │
└────────┬─────────┘
         │
         ▼
┌─────────────────────────────┐
│   Nginx (Reverse Proxy)     │  ← Routes to app-service:5000
│   NodePort: 30080           │
│   (1 replica)               │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│   Flask App (app-service)   │  ← Connects to mysql-service:3306
│   ClusterIP Port: 5000      │
│   (2 replicas - load balanced)
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│   MySQL Database            │  ← Persists data in PersistentVolume
│   ClusterIP Port: 3306      │
│   (1 replica)               │
└─────────────────────────────┘
```

---

## ✅ What You Should See

### In Browser (http://192.168.49.2:30080):
- **Student Management System** heading
- Form to add students (Name, Email)
- Table showing existing students:
  - ID: 1, John Doe, john@example.com
  - ID: 2, Jane Smith, jane@example.com
- Delete buttons for each student

### In Terminal (kubectl get pods):
```
NAME                                READY   STATUS    RESTARTS
app-deployment-dccb69659-2w9jt      1/1     Running   0
app-deployment-dccb69659-mhxtb      1/1     Running   0
mysql-deployment-876c6fcd8-5phkm    1/1     Running   0
nginx-deployment-7796748c5f-2jg2k   1/1     Running   0
```

### In Terminal (curl health check):
```json
{"database":"connected","status":"ok"}
```

---

## 🔄 Key Features Demonstrated

✅ **3-Tier Layered Architecture** - Separate containers for each layer
✅ **Nginx Reverse Proxy** - Routes external traffic to Flask app
✅ **Load Balancing** - 2 Flask app replicas behind app-service
✅ **Service Discovery** - DNS-based communication (app-service, mysql-service)
✅ **Persistent Storage** - MySQL data persists in PersistentVolume
✅ **Health Checks** - Liveness/readiness probes on all containers
✅ **Environment Configuration** - ConfigMaps for database initialization
✅ **Resource Limits** - Memory and CPU limits set for all containers
✅ **Database Initialization** - Automatic schema creation with sample data

---

## 📞 Need Help?

Check logs:
```bash
kubectl logs deployment/<component>
kubectl describe pod <pod-name>
kubectl get events --sort-by='.lastTimestamp'
```

Delete and redeploy:
```bash
kubectl delete -f k8s/
kubectl apply -f k8s/
```

Check connectivity:
```bash
kubectl exec <pod> -- curl http://app-service:5000/health
```
