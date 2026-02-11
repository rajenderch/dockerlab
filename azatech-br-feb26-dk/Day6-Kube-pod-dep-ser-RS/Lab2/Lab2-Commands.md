## deployment Kube files

inside Lab2, there is deployment.yaml and service.yaml


Inside the folder 
```
kubectl apply -f .
kubectl get pods 
kubectl get rs
kubectl get deployment

kubectl get svc
```

* delete a pod 
```
kubectl delete pod <pod-name>
```
sample of pod name in deployment -- deploymentname-replicaset-podvalue

* observe that the service.yaml file is the same use din lab1


* scale the pods
```
kubectl scale deployment nginx-deployment --replicas=5
kubectl get pods 
kubectl get rs
```

* lets add the replica in the yaml file
```
replicas: 5
```
Note: to be added below the first spec:

kubectl describe pod <podname>  | grep image

* Lets test the rollout 
```
kubectl set image deployment/nginx-deployment nginx-container=nginx:1.26
kubectl rollout status deployment nginx-deployment
```

* Check the progress of the rollout 
```
kubectl rollout history deployment nginx-deployment
```

* To confirm if the pod has been changed
```
kubectl describe pod pod-name  | grep image
```

* Finally test the rollback
```
kubectl rollout undo deployment nginx-deployment
```

* Testing the resource limit, add the below and push to jenkins 
```
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"
```


