# Lab 2: Pod Manifest (Infrastructure as Code)

## Objective
Create a Pod using YAML manifest - the declarative and recommended approach.

## Duration
~20 minutes

## Prerequisites
- Completed Lab 1
- Text editor available
- Understanding of YAML format

## What You'll Learn
- Writing Kubernetes manifests
- Pod specification structure
- Deploying from YAML files
- Declarative vs Imperative approaches

---

## Understanding YAML Manifests

A Kubernetes manifest defines desired state in a declarative way.

### Basic Structure

```yaml
apiVersion: v1           # API version
kind: Pod               # Type of object
metadata:               # Object metadata
  name: my-app
  labels:
    app: my-app
spec:                   # Object specification
  containers:
  - name: app-container
    image: nginx:latest
    ports:
    - containerPort: 80
```

---

## Exercise Steps

### Step 1: Create a Pod Manifest

Create file: `my-first-pod.yaml`

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

**Save this file and proceed to next step.**

### Step 2: Apply the Manifest

```bash
kubectl apply -f my-first-pod.yaml
```

**Output:**
```
pod/nginx-manifest created
```

### Step 3: Verify Pod Creation

```bash
kubectl get pods
kubectl describe pod nginx-manifest
```

### Step 4: Create a Multi-Container Pod

Create file: `multi-container-pod.yaml`

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

**Note:** This Pod has two containers sharing the same network namespace.

### Step 5: Apply Multi-Container Pod

```bash
kubectl apply -f multi-container-pod.yaml
```

### Step 6: Access Specific Container

```bash
# Execute in specific container
kubectl exec -it multi-container-pod -c web-server -- /bin/bash

# From the same pod, access port 80
kubectl exec -it multi-container-pod -c helper -- wget -O- http://localhost
```

### Step 7: Create Pod with Environment Variables

Create file: `pod-with-env.yaml`

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

### Step 8: Verify Environment Variables

```bash
# View environment variables
kubectl exec app-with-env -- env | grep APP

# Or print them
kubectl exec app-with-env -- printenv
```

### Step 9: Update Pod Manifest

Edit `my-first-pod.yaml` to add labels:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-manifest
  labels:
    app: nginx
    environment: learning
    team: platform  # Add new label
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

### Step 10: Apply Updated Manifest

```bash
kubectl apply -f my-first-pod.yaml
```

Check the update:
```bash
kubectl get pod nginx-manifest -o wide
kubectl get pod nginx-manifest --show-labels
```

### Step 11: Delete Using Manifest

```bash
kubectl delete -f my-first-pod.yaml
kubectl delete -f multi-container-pod.yaml
kubectl delete -f pod-with-env.yaml
```

---

## Manifest Structure Deep Dive

### apiVersion
- `v1`: Core API (Pods, Services, ConfigMaps, etc.)
- `apps/v1`: Apps API (Deployments, StatefulSets)
- `batch/v1`: Batch API (Jobs, CronJobs)

### kind
What type of Kubernetes object:
- Pod, Service, Deployment, ConfigMap, Secret, etc.

### metadata
Information about the object:
- `name`: Unique name
- `namespace`: Which namespace (default is "default")
- `labels`: Key-value pairs for organization
- `annotations`: Extra metadata for tooling

### spec
Desired state specification - varies by kind

---

## Labels and Selectors

Labels are key-value pairs for organizing resources:

```yaml
metadata:
  labels:
    app: myapp
    environment: dev
    team: platform
```

Query by labels:
```bash
# Find pods with label
kubectl get pods -l app=myapp

# Multiple selectors
kubectl get pods -l app=myapp,environment=dev

# Show labels
kubectl get pods --show-labels
```

---

## Resource Limits and Requests

**Requests**: Minimum resources guaranteed
**Limits**: Maximum resources allowed

```yaml
resources:
  requests:
    memory: "64Mi"    # Guaranteed minimum
    cpu: "100m"       # 100 millicores
  limits:
    memory: "128Mi"   # Maximum allowed
    cpu: "200m"
```

Units:
- CPU: `m` = millicores, `1000m` = 1 core
- Memory: `Mi` = Mebibytes, `Gi` = Gibibytes

---

## Challenges

1. **Create a Pod with init container**
   - Init containers run before main containers
   - Use `initContainers` in spec

2. **Create a Pod with volumeMounts**
   - See Day 2 materials for storage

3. **Create Pod with health checks**
   - Use `livenessProbe` and `readinessProbe`

---

## Troubleshooting

### YAML Syntax Error
```bash
# Validate YAML syntax
kubectl apply -f my-pod.yaml --dry-run=client

# Get detailed error
kubectl describe pod <name>
```

### CrashLoopBackOff Status
```bash
# Check logs
kubectl logs <pod-name>

# Check events
kubectl describe pod <pod-name>
```

---

## Key Commands

| Command | Purpose |
|---------|---------|
| `kubectl apply -f file.yaml` | Create/update from manifest |
| `kubectl create -f file.yaml` | Create only (fails if exists) |
| `kubectl delete -f file.yaml` | Delete using manifest |
| `kubectl get pods --show-labels` | Show pod labels |
| `kubectl get pods -l app=myapp` | Filter by label |
| `kubectl apply --dry-run=client -f file.yaml` | Validate without creating |

---

## Files to Create for This Lab

- `my-first-pod.yaml` - Simple single-container Pod
- `multi-container-pod.yaml` - Pod with 2 containers
- `pod-with-env.yaml` - Pod with environment variables

---

## What's Next?

- Lab 3: Managing multiple Pods with selectors
- Lab 4: Deployments for production use

---

## Notes

- **Declarative approach** (manifests) is the Kubernetes way
- **Imperative approach** (kubectl run) is for learning/testing
- Always version control your manifests
- Use meaningful labels for organization
- Set resource limits to prevent resource exhaustion

