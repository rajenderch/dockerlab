#!/bin/bash

echo "════════════════════════════════════════════════════════════════"
echo "  STUDENT MANAGEMENT APP - KUBERNETES DEPLOYMENT DEMO"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Get minikube IP
MINIKUBE_IP=$(minikube ip)
APP_URL="http://$MINIKUBE_IP:30080"

echo "📍 DEPLOYMENT INFORMATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Minikube IP:      $MINIKUBE_IP"
echo "Application URL:  $APP_URL"
echo "NodePort:         30080"
echo ""

echo "📦 KUBERNETES COMPONENTS STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🐳 Running Pods:"
kubectl get pods -o wide
echo ""

echo "🔌 Services:"
kubectl get svc -o wide
echo ""

echo "📊 Deployments:"
kubectl get deployments
echo ""

echo "💾 Storage:"
kubectl get pvc
echo ""

echo "🧪 TESTING THE APPLICATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "✅ Test 1: Health Check"
echo "Command: curl http://$MINIKUBE_IP:30080/health"
HEALTH=$(curl -s $APP_URL/health)
echo "Response: $HEALTH"
echo ""

echo "✅ Test 2: Main Application Page"
echo "Command: curl http://$MINIKUBE_IP:30080/"
echo "Sample output:"
curl -s $APP_URL/ | grep -A 5 "<h1>" | head -10
echo ""

echo "✅ Test 3: Database Connectivity"
echo "Command: kubectl logs deployment/app-deployment | head -20"
echo "App logs:"
kubectl logs deployment/app-deployment --tail=5
echo ""

echo "✅ Test 4: Student Data from Database"
echo "Current students in database:"
curl -s $APP_URL/ | grep -E '<td>[0-9]|<td>[A-Z]|<td>[a-z]' | sed 's/<[^>]*>//g' | sed 's/^ *//' | paste - - - | head -5
echo ""

echo "🌐 HOW TO ACCESS THE APPLICATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Option 1: Open in browser (automatic)"
echo "  minikube service nginx-service"
echo ""
echo "Option 2: Direct URL"
echo "  $APP_URL"
echo ""
echo "Option 3: Port forward (if needed)"
echo "  kubectl port-forward svc/nginx-service 8080:80"
echo "  Then visit: http://localhost:8080"
echo ""

echo "📋 USEFUL COMMANDS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "View logs:"
echo "  kubectl logs -f deployment/app-deployment"
echo "  kubectl logs -f deployment/mysql-deployment"
echo "  kubectl logs -f deployment/nginx-deployment"
echo ""
echo "Connect to MySQL:"
echo "  kubectl exec -it <mysql-pod> -- mysql -u root -prootpassword"
echo ""
echo "Get pod details:"
echo "  kubectl describe pod <pod-name>"
echo ""
echo "Watch pod status:"
echo "  kubectl get pods -w"
echo ""

echo "🗑️  CLEANUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "To remove all deployments:"
echo "  kubectl delete -f k8s/"
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "✨ Application is ready! Visit: $APP_URL"
echo "════════════════════════════════════════════════════════════════"
