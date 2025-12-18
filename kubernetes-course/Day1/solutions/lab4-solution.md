# Lab 4 Solution: Deployments

## Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
```

## Key Commands

```bash
# Create deployment
kubectl apply -f nginx-deployment.yaml

# Check deployment status
kubectl get deployments
kubectl describe deployment nginx-deployment

# List pods created by deployment
kubectl get pods -l app=nginx

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5
kubectl scale deployment nginx-deployment --replicas=2

# Update image (rolling update)
kubectl set image deployment/nginx-deployment nginx=nginx:1.22 --record

# Check rollout status
kubectl rollout status deployment/nginx-deployment
kubectl rollout status deployment/nginx-deployment -w

# View rollout history
kubectl rollout history deployment/nginx-deployment
kubectl rollout history deployment/nginx-deployment --revision=2

# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment
kubectl rollout undo deployment/nginx-deployment --to-revision=1

# Edit and update
kubectl apply -f nginx-deployment.yaml

# Delete deployment
kubectl delete deployment nginx-deployment
```

## Deployment Strategies

### RollingUpdate (Default - Zero Downtime)
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1           # Extra pods during update
    maxUnavailable: 0     # Never have unavailable pods
```

### Recreate (Downtime but Simple)
```yaml
strategy:
  type: Recreate
```

## Health Checks

### Readiness Probe
```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 10
```

### Liveness Probe
```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 15
  periodSeconds: 20
```

## Self-Healing Example

```bash
# Delete a pod
kubectl delete pod <pod-name>

# Watch it auto-recreate
kubectl get pods -w

# Deployment maintains desired replicas
```

## Deployment Lifecycle

1. Creating → Progressing → Available
2. Rolling updates: Old pods replaced gradually
3. Automatic rollback on failure
4. Self-healing: Recreates failed pods

## Practical Workflow

```bash
# 1. Create deployment
kubectl apply -f nginx-deployment.yaml

# 2. Monitor pods
kubectl get pods -w

# 3. Scale as needed
kubectl scale deployment nginx-deployment --replicas=5

# 4. Update image (rolling)
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# 5. Verify update
kubectl rollout status deployment/nginx-deployment

# 6. If needed, rollback
kubectl rollout undo deployment/nginx-deployment

# 7. Clean up
kubectl delete deployment nginx-deployment
```

## Troubleshooting

```bash
# Check deployment status
kubectl describe deployment nginx-deployment

# View events
kubectl get events

# Check logs of pods
kubectl logs -l app=nginx --tail=50

# Check replica status
kubectl get rs -l app=nginx
```

## Key Insights

- Deployments manage ReplicaSets automatically
- Always use Deployments, not standalone Pods
- Rolling updates ensure zero downtime
- Self-healing is automatic
- Rollback history is tracked
- Labels connect Deployments to Pods
