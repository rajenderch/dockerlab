
```bash
minikube start
```

If you need additional options, here are some common ones:

```bash
# Start with specific driver (docker, virtualbox, kvm2, etc.)
minikube start --driver=docker

# Start with specific memory allocation
minikube start --memory=4096

# Start and set kubectl context
minikube start && kubectl config use-context minikube
```

Once minikube is running, you can deploy your service and pod with:

```bash
# From your lab1 directory
kubectl apply -f pod.yaml
kubectl apply -f service.yaml

# Verify they're running
kubectl get pods
kubectl get svc
```

To access your nginx service:
```bash
minikube service nginx-service
```

Would you like help with any of these commands or your Kubernetes configuration?

User: what is the difference between " kubectl apply -f . "  Vs " kubectl apply -f pod.yaml
kubectl apply -f service.yaml "  commands ? 

GitHub Copilot: The main difference is **scope and how many files are applied**:

**`kubectl apply -f .`**
- Applies **all YAML files** in the current directory recursively
- Convenient for deploying an entire application stack at once
- Useful when you have multiple resource files and want to deploy them all together
- Less control over which files are applied

**`kubectl apply -f pod.yaml` + `kubectl apply -f service.yaml`**
- Applies **specific files individually**
- More explicit and controlled - you choose exactly which resources to deploy
- Better for incremental deployments or when you want to apply only certain resources
- Easier to troubleshoot since you can apply and verify each resource separately

**For your lab setup**, since you have both `pod.yaml` and `service.yaml` in the same directory, you could use either:

```bash
# Option 1: Apply both individually (what you're doing)
kubectl apply -f pod.yaml
kubectl apply -f service.yaml

# Option 2: Apply all at once
kubectl apply -f .
```

**Best practice tip**: In a production environment, it's often better to use `kubectl apply -f .` or apply a specific manifest that includes all resources, so everything is deployed together and stays in sync. For learning/lab environments, applying individually helps you understand each component.

User: explain in datils abour below output "  (base) labuser@ip-172-31-44-10:~/Documents/Project/Day6-kube-pod/lab1$ kubectl get pods
NAME                     READY   STATUS    RESTARTS      AGE
nginx-56c45fd5ff-tq92c   1/1     Running   1 (11h ago)   15h
nginx-pod                1/1     Running   1 (11h ago)   11h
" 

GitHub Copilot: Here's a detailed breakdown of that `kubectl get pods` output:

**Column Headers:**
- **NAME** - The name of the pod
- **READY** - Shows `current_ready/total_containers` (how many containers are ready vs total)
- **STATUS** - The current state of the pod
- **RESTARTS** - How many times the pod has been restarted
- **AGE** - How long the pod has been running

**Row 1: `nginx-56c45fd5ff-tq92c`**
- **NAME**: This is a Deployment-managed pod (the hash `56c45fd5ff` is auto-generated)
- **READY**: `1/1` - 1 container is ready out of 1 total container
- **STATUS**: `Running` - Pod is actively running
- **RESTARTS**: `1 (11h ago)` - The pod has restarted once, and that restart happened 11 hours ago
- **AGE**: `15h` - Pod has existed for 15 hours

**Row 2: `nginx-pod`**
- **NAME**: This appears to be a standalone pod (matches the name in your `pod.yaml`)
- **READY**: `1/1` - 1 container is ready out of 1 total container
- **STATUS**: `Running` - Pod is actively running
- **RESTARTS**: `1 (11h ago)` - Same restart pattern as above
- **AGE**: `11h` - Pod has existed for 11 hours

**Key Observations:**
- Both pods are healthy and running
- The first pod is likely created by a **Deployment** (auto-managed replicas)
- The second pod is your **standalone nginx-pod** from your `pod.yaml`
- Both had one restart 11 hours ago (possibly due to system reboot or crash)
- Both are receiving traffic successfully since they show `1/1 Ready`

User: what is the meaning of this output "  (base) labuser@ip-172-31-44-10:~/Documents/Project/Day6-kube-pod/lab1$ kubectl get svc
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP        15h
nginx           NodePort    10.111.229.22   <none>        80:31523/TCP   15h
nginx-service   NodePort    10.105.34.206   <none>        80:30007/TCP   11h"

GitHub Copilot: Here's a detailed breakdown of that `kubectl get svc` (services) output:

**Column Headers:**
- **NAME** - Service name
- **TYPE** - Service type (ClusterIP, NodePort, LoadBalancer, etc.)
- **CLUSTER-IP** - Internal IP address within the Kubernetes cluster
- **EXTERNAL-IP** - External IP (shows `<none>` for NodePort in minikube)
- **PORT(S)** - Port mappings (internal:external)
- **AGE** - How long the service has existed

**Row 1: `kubernetes`**
- **TYPE**: `ClusterIP` - Internal-only service (default)
- **CLUSTER-IP**: `10.96.0.1` - The API server's internal address
- **PORT(S)**: `443/TCP` - Kubernetes API runs on port 443
- **AGE**: `15h` - System service created with the cluster
- This is the **default Kubernetes API service** (always present)

**Row 2: `nginx`**
- **TYPE**: `NodePort` - Exposes service on a node port
- **CLUSTER-IP**: `10.111.229.22` - Internal cluster address
- **PORT(S)**: `80:31523/TCP` - Maps port 80 (container) to port 31523 (node)
- **AGE**: `15h` - Created 15 hours ago
- This appears to be from a **Deployment** you created earlier

**Row 3: `nginx-service`** (your service.yaml)
- **TYPE**: `NodePort` - Exposes service on a node port
- **CLUSTER-IP**: `10.105.34.206` - Internal cluster address
- **PORT(S)**: `80:30007/TCP` - Maps port 80 (container) to port 30007 (node)
- **AGE**: `11h` - Created 11 hours ago
- This is the **service from your current service.yaml**

**Key Difference:**
- `nginx` uses auto-assigned port `31523` (random)
- `nginx-service` uses explicitly defined port `30007` (as you specified in your YAML)

To access nginx-service from minikube: `minikube service nginx-service` or `http://<minikube-ip>:30007`

User: what are the other inforamtive kubernetes we can run on above inforamtion for more clarity 

GitHub Copilot: Here are useful kubectl commands to get more clarity on your nginx setup:

**1. Get detailed pod information:**
```bash
kubectl get pods -o wide
# Shows: NODE, IP, NOMINATED NODE, READINESS GATES
```

**2. Describe a specific pod (detailed info):**
```bash
kubectl describe pod nginx-pod
kubectl describe pod nginx-56c45fd5ff-tq92c
# Shows: Events, containers, volumes, resource usage, status details
```

**3. Describe the service:**
```bash
kubectl describe svc nginx-service
# Shows: Endpoints (which pods it's routing to), selector, port mappings
```

**4. Get endpoints (which pods are behind the service):**
```bash
kubectl get endpoints
kubectl get endpoints nginx-service
# Shows IP:port of pods the service is routing traffic to
```

**5. Check service selector matching:**
```bash
kubectl get pods --show-labels
# Shows labels on each pod (helps verify service selector is matching)
```

**6. View logs from a pod:**
```bash
kubectl logs nginx-pod
kubectl logs nginx-56c45fd5ff-tq92c
# Shows application output/errors
```

**7. Get all resources:**
```bash
kubectl get all
# Shows all pods, services, deployments, replicasets in one view
```

**8. Check resource usage:**
```bash
kubectl top pods
kubectl top nodes
# Shows CPU and memory usage
```

**9. Get events:**
```bash
kubectl get events
# Shows recent cluster events (pod creation, restarts, errors)
```

**10. Check labels and selectors:**
```bash
kubectl get pods -L app
# Shows pods with their 'app' label value (helps verify service-pod matching)
```