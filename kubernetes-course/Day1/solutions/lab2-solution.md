# Lab 2 Solution: Pod Manifests

## YAML Files Created

### Simple Pod Manifest
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-manifest
  labels:
    app: nginx
    environment: learning
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
    ports:
    - containerPort: 80
      protocol: TCP
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "200m"
```

### Multi-Container Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
  labels:
    app: multi-container
spec:
  containers:
  - name: web-server
    image: nginx:latest
    ports:
    - containerPort: 80
    
  - name: helper
    image: busybox:latest
    command: ["sleep", "3600"]
```

### Pod with Environment Variables
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-env
  labels:
    app: myapp
spec:
  containers:
  - name: app
    image: nginx:latest
    ports:
    - containerPort: 8080
    env:
    - name: APP_NAME
      value: "MyApp"
    - name: ENVIRONMENT
      value: "learning"
    - name: DEBUG
      value: "true"
```

## Commands to Execute

```bash
# Apply manifests
kubectl apply -f my-first-pod.yaml
kubectl apply -f multi-container-pod.yaml
kubectl apply -f pod-with-env.yaml

# View pods
kubectl get pods
kubectl get pods --show-labels

# Check environment variables
kubectl exec app-with-env -- env | grep APP

# Delete by manifest
kubectl delete -f my-first-pod.yaml
```

## Key Concepts

1. **apiVersion: v1** - Core Kubernetes API
2. **kind: Pod** - Object type
3. **metadata** - Labels for organization
4. **spec.containers** - Container definitions
5. **resources** - Memory and CPU limits
6. **env** - Environment variables
7. **ports** - Container ports exposed

## Best Practices

- Always use labels for organization
- Set resource requests and limits
- Use meaningful container names
- Include port information
- Keep manifests in version control
