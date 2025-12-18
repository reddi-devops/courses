# Lab 4: Introduction to Deployments

## Objective
Create and manage Deployments - the recommended way to run Pods in production.

## Duration
~30 minutes

## Prerequisites
- Completed Lab 1-3
- Understanding of Pods and labels
- YAML manifest knowledge

## What You'll Learn
- Deployment concepts and benefits
- Creating Deployments declaratively
- Scaling applications
- Rolling updates
- Self-healing capabilities
- Deployment strategies

---

## Why Deployments?

**Pods** are ephemeral and don't self-heal. **Deployments** provide:
- ✅ Automatic pod creation and management
- ✅ Scaling up/down replicas
- ✅ Rolling updates with zero downtime
- ✅ Automatic rollback on failures
- ✅ Health checks and self-healing

---

## Deployment Structure

```yaml
apiVersion: apps/v1           # Apps API, not v1!
kind: Deployment              # Type
metadata:
  name: my-app
spec:
  replicas: 3                 # Number of pod copies
  selector:                   # Label selector for pods
    matchLabels:
      app: my-app
  template:                   # Pod template
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:latest
```

---

## Exercise Steps

### Step 1: Create Your First Deployment

Create file: `nginx-deployment.yaml`

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
```

### Step 2: Apply the Deployment

```bash
kubectl apply -f nginx-deployment.yaml
```

### Step 3: Check Deployment Status

```bash
kubectl get deployments
```

**Output shows:**
- NAME, READY, UP-TO-DATE, AVAILABLE, AGE

### Step 4: View Pods Created by Deployment

```bash
kubectl get pods
```

Notice 3 Pods were created automatically with names like:
- nginx-deployment-5f7b8c6d9-xxxxx
- nginx-deployment-5f7b8c6d9-yyyyy
- nginx-deployment-5f7b8c6d9-zzzzz

The suffix is auto-generated.

### Step 5: Check Deployment Details

```bash
kubectl describe deployment nginx-deployment
```

Shows:
- Replicas information
- Pod template details
- Events (creation history)
- Conditions

### Step 6: Scale the Deployment

Increase replicas to 5:

```bash
kubectl scale deployment nginx-deployment --replicas=5
```

**Verify scaling:**
```bash
kubectl get pods
kubectl get deployment nginx-deployment
```

### Step 7: Scale Down

Decrease replicas to 2:

```bash
kubectl scale deployment nginx-deployment --replicas=2
```

### Step 8: Update Image (Rolling Update)

Update to nginx 1.22:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.22 --record
```

The `--record` flag records the change for rollback history.

### Step 9: Check Rollout Status

```bash
kubectl rollout status deployment/nginx-deployment
```

Watch the rolling update progress:
```bash
kubectl rollout status deployment/nginx-deployment -w
```

### Step 10: View Rollout History

```bash
kubectl rollout history deployment/nginx-deployment
```

Shows all revisions.

### Step 11: Detailed Rollout History

```bash
kubectl rollout history deployment/nginx-deployment --revision=2
```

Shows details of specific revision.

### Step 12: Rollback to Previous Version

If something goes wrong, rollback:

```bash
kubectl rollout undo deployment/nginx-deployment
```

**Verify rollback:**
```bash
kubectl rollout status deployment/nginx-deployment
kubectl rollout history deployment/nginx-deployment
```

### Step 13: Rollback to Specific Revision

```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=1
```

### Step 14: Get Deployment YAML

```bash
kubectl get deployment nginx-deployment -o yaml
```

### Step 15: Update Deployment via Manifest

Edit `nginx-deployment.yaml` to change replicas:

```yaml
spec:
  replicas: 4
```

Apply the change:

```bash
kubectl apply -f nginx-deployment.yaml
```

---

## Deployment Strategies

### Rolling Update (Default)
- Gradually replace old pods with new ones
- Zero downtime
- Controlled by `maxSurge` and `maxUnavailable`

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1           # Max extra pods during update
      maxUnavailable: 1     # Max unavailable during update
```

### Recreate
- Delete all old pods first, then create new ones
- May cause downtime
- Faster for testing

```yaml
spec:
  strategy:
    type: Recreate
```

---

## Health Checks (Probes)

### Readiness Probe
Checks if Pod is ready to receive traffic:

```yaml
spec:
  containers:
  - name: nginx
    image: nginx:latest
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
```

### Liveness Probe
Checks if Pod is alive; restarts if fails:

```yaml
spec:
  containers:
  - name: nginx
    image: nginx:latest
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 15
      periodSeconds: 20
```

---

## Exercise: Advanced Deployment

Create file: `app-deployment.yaml` with health checks:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
        version: v1
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
```

Apply and test:

```bash
kubectl apply -f app-deployment.yaml
kubectl get deployment app-deployment -w
```

---

## Key Deployment Commands

| Command | Purpose |
|---------|---------|
| `kubectl create deployment <name> --image=<image>` | Create deployment |
| `kubectl get deployments` | List deployments |
| `kubectl describe deployment <name>` | Deployment details |
| `kubectl scale deployment <name> --replicas=N` | Scale replicas |
| `kubectl set image deployment/<name> <container>=<image>` | Update image |
| `kubectl rollout status deployment/<name>` | Check rollout status |
| `kubectl rollout history deployment/<name>` | View revision history |
| `kubectl rollout undo deployment/<name>` | Rollback to previous |
| `kubectl delete deployment <name>` | Delete deployment |

---

## Deployment Lifecycle

1. **Creating**: Initial deployment creation
2. **Progressing**: Rolling out new pods
3. **Available**: Desired replicas ready
4. **Scaling**: Replicas being adjusted
5. **Rolling Update**: Old pods replaced with new
6. **Rollback**: Reverting to previous version

---

## Challenges

1. **Test self-healing**
   - Delete a pod from deployment
   - Watch it auto-recreate
   ```bash
   kubectl delete pod <pod-name>
   kubectl get pods -w
   ```

2. **Test rolling update**
   - Update image and watch progress
   - Rollback and verify pods restart

3. **Horizontal scaling**
   - Scale up to 10 replicas
   - Scale down to 1
   - Watch pods change

4. **Check resource usage**
   ```bash
   kubectl top deployment nginx-deployment
   ```

---

## Troubleshooting

### Pods stuck in Pending
```bash
kubectl describe deployment nginx-deployment
kubectl get events
```

### Update not rolling
```bash
kubectl rollout status deployment/nginx-deployment -w
```

### Need to cancel rollout
```bash
kubectl rollout pause deployment/nginx-deployment
```

---

## Cleanup

```bash
kubectl delete deployment nginx-deployment
kubectl delete deployment app-deployment
kubectl delete -f nginx-deployment.yaml
```

---

## What's Next?

- Lab 5: Services (expose Deployments to network)
- Day 2: Persistent storage and ConfigMaps
- Day 3: Multi-replica scaling and resource management

---

## Notes

- Deployments are the standard way to run applications
- Always use Deployments, not standalone Pods
- Labels connect Deployments to Pods
- Rolling updates ensure zero downtime
- Always set resource requests/limits
- Health checks improve reliability

