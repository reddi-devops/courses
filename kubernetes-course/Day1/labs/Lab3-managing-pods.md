# Lab 3: Managing Pods - Labels, Selectors, and Advanced Operations

## Objective
Learn to manage multiple Pods using labels, selectors, and perform advanced Pod operations.

## Duration
~25 minutes

## Prerequisites
- Completed Lab 1 and Lab 2
- Understanding of Pod basics
- YAML manifest knowledge

## What You'll Learn
- Using labels and selectors
- Organizing Pods efficiently
- Updating Pod properties
- Advanced filtering and queries
- Pod lifecycle management

---

## Understanding Labels and Selectors

**Labels**: Key-value pairs attached to Kubernetes objects for organization and selection.

**Selectors**: Query language to find objects based on labels.

### Example Use Cases
- Group Pods by application: `app: nginx`
- Separate by environment: `environment: production`
- Organize by team: `team: backend`
- Version tracking: `version: v1.2.3`

---

## Exercise Steps

### Step 1: Create Pods with Different Labels

Create file: `labeled-pods.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-frontend-1
  labels:
    app: myapp
    tier: frontend
    environment: production
spec:
  containers:
  - name: nginx
    image: nginx:latest

---
apiVersion: v1
kind: Pod
metadata:
  name: app-frontend-2
  labels:
    app: myapp
    tier: frontend
    environment: production
spec:
  containers:
  - name: nginx
    image: nginx:latest

---
apiVersion: v1
kind: Pod
metadata:
  name: app-backend-1
  labels:
    app: myapp
    tier: backend
    environment: production
spec:
  containers:
  - name: app
    image: nginx:latest

---
apiVersion: v1
kind: Pod
metadata:
  name: app-backend-dev
  labels:
    app: myapp
    tier: backend
    environment: development
spec:
  containers:
  - name: app
    image: nginx:latest
```

### Step 2: Apply the Manifest

```bash
kubectl apply -f labeled-pods.yaml
```

### Step 3: Query by Single Label

Find all frontend Pods:

```bash
kubectl get pods -l tier=frontend
```

Find all production Pods:

```bash
kubectl get pods -l environment=production
```

### Step 4: Query by Multiple Labels (AND condition)

Find Pods that are both frontend AND production:

```bash
kubectl get pods -l tier=frontend,environment=production
```

### Step 5: Query by Label Operators

```bash
# Equal: app=myapp
kubectl get pods -l app=myapp

# Not equal: environment!=production
kubectl get pods -l environment!=production

# In a set: environment in (production, development)
kubectl get pods -l "environment in (production, development)"

# Not in set: tier notin (frontend)
kubectl get pods -l "tier notin (frontend)"

# Key exists: has label "app"
kubectl get pods -l app

# Key does not exist: no label "version"
kubectl get pods -l '!version'
```

### Step 6: Show All Labels

```bash
kubectl get pods --show-labels
```

### Step 7: Output Labels as Columns

```bash
kubectl get pods -L tier,environment
```

This displays tier and environment as columns.

### Step 8: Add Labels to Existing Pod

```bash
# Add label to a running Pod
kubectl label pod app-frontend-1 team=frontend-team

# Verify
kubectl get pod app-frontend-1 --show-labels
```

### Step 9: Update Existing Labels

```bash
# Change label value
kubectl label pod app-frontend-1 environment=staging --overwrite

# Verify change
kubectl get pod app-frontend-1 -L environment
```

### Step 10: Remove Labels

```bash
# Remove label (use "-" after key)
kubectl label pod app-frontend-1 team-

# Verify removal
kubectl get pod app-frontend-1 --show-labels
```

### Step 11: Get Pod Details in YAML

```bash
# Output single pod as YAML
kubectl get pod app-frontend-1 -o yaml

# Save to file
kubectl get pod app-frontend-1 -o yaml > backup-pod.yaml
```

### Step 12: Edit Pod (only metadata is editable)

```bash
kubectl edit pod app-frontend-1
```

This opens default editor to modify labels/annotations only.

### Step 13: Describe Pods with Label Selector

```bash
kubectl describe pods -l tier=backend
```

### Step 14: Delete Pods by Label Selector

**Delete all development Pods:**

```bash
kubectl delete pods -l environment=development
```

**Verify deletion:**
```bash
kubectl get pods
```

### Step 15: More Advanced Queries

Count Pods by tier:
```bash
kubectl get pods -L tier --no-headers | awk '{print $6}' | sort | uniq -c
```

Get all Pods with specific labels and output in JSON:
```bash
kubectl get pods -l app=myapp -o json
```

---

## Label Naming Best Practices

```yaml
metadata:
  labels:
    # Common labels
    app.kubernetes.io/name: myapp
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/component: frontend
    app.kubernetes.io/part-of: myapp-system
    app.kubernetes.io/managed-by: helm
    
    # Custom labels
    environment: production
    team: platform
    cost-center: engineering
```

---

## Advanced Pod Operations

### Get Pod IP and Node

```bash
kubectl get pods -o wide
```

Shows: NAME, READY, STATUS, RESTARTS, AGE, **IP**, **NODE**

### Get Pod Events

```bash
kubectl get events --sort-by='.lastTimestamp'
```

### Watch Pod Status

```bash
# Continuously watch pods
kubectl get pods -w

# Watch specific pod
kubectl get pod app-frontend-1 -w
```

### Port Forward to Specific Pod

```bash
kubectl port-forward pod/app-frontend-1 8080:80 &
```

---

## Annotation vs Labels

**Labels**: For selection and identification
```yaml
labels:
  app: myapp
  tier: frontend
```

**Annotations**: For metadata and tooling (not used for selection)
```yaml
annotations:
  description: "Frontend nginx server"
  contact: "team@example.com"
  deployment.version: "2.1.5"
```

---

## Challenges

1. **Create a pod selector query**
   - Find all Pods not in production environment
   - Find all Pods with `app=myapp` label

2. **Bulk operations**
   - Add a label to multiple Pods using selector
   - Delete all dev Pods with single command

3. **Export configuration**
   - Export all Pods with `tier=frontend` as YAML
   - Save to a file

---

## Commands Summary

| Command | Purpose |
|---------|---------|
| `kubectl get pods -l label=value` | Query by label |
| `kubectl get pods --show-labels` | Show all labels |
| `kubectl get pods -L key1,key2` | Show specific labels as columns |
| `kubectl label pod name key=value` | Add label |
| `kubectl label pod name key=value --overwrite` | Update label |
| `kubectl label pod name key-` | Remove label |
| `kubectl delete pods -l label=value` | Delete by selector |
| `kubectl get pod name -o yaml` | Export as YAML |
| `kubectl describe pods -l label=value` | Describe multiple pods |

---

## Troubleshooting

### Label Selector Not Working
```bash
# Verify label exists
kubectl get pods --show-labels

# Check for typos in label names/values
# Labels are case-sensitive
```

### Cannot Edit Pod Directly
```bash
# Can only edit: labels, annotations
# Cannot change: image, ports, etc.
# Must delete and recreate for other changes
```

---

## What's Next?

After mastering labels and selectors:
- Lab 4: Deployments (manages multiple Pods with labels)
- Lab 5: Services (use selectors to route traffic)

---

## Notes

- Labels are fundamental to Kubernetes organization
- Use consistent labeling schemes across team
- Selectors are used by Services, Deployments, etc.
- Always plan your labeling strategy early
- Can add/update labels on running Pods without restart

