# Lab 3 Solution: Managing Pods with Labels and Selectors

## Label Commands Summary

```bash
# Add labels when creating
kubectl run frontend-1 --image=nginx -l "app=myapp,tier=frontend"

# Query by single label
kubectl get pods -l tier=frontend
kubectl get pods -l environment=production

# Query by multiple labels (AND condition)
kubectl get pods -l tier=frontend,environment=production

# Query by operators
kubectl get pods -l "environment!=production"
kubectl get pods -l "environment in (production, development)"
kubectl get pods -l "tier notin (frontend)"

# Check for label existence
kubectl get pods -l app
kubectl get pods -l '!version'

# Show labels as columns
kubectl get pods -L tier,environment
kubectl get pods --show-labels
```

## Label Management Commands

```bash
# Add label to existing pod
kubectl label pod app-frontend-1 team=frontend-team

# Update label value
kubectl label pod app-frontend-1 environment=staging --overwrite

# Remove label
kubectl label pod app-frontend-1 team-

# Check changes
kubectl get pod app-frontend-1 --show-labels
```

## Example Manifest with Labels

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
```

## Advanced Queries

```bash
# Get Pod IP and Node
kubectl get pods -o wide

# Export as YAML
kubectl get pod app-frontend-1 -o yaml > backup-pod.yaml

# Describe multiple pods by selector
kubectl describe pods -l tier=backend

# Delete pods by selector
kubectl delete pods -l environment=development

# Count pods by label
kubectl get pods -L tier --no-headers | awk '{print $6}' | sort | uniq -c
```

## Label Best Practices

```yaml
metadata:
  labels:
    # Recommended labels
    app.kubernetes.io/name: myapp
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/component: frontend
    app.kubernetes.io/managed-by: helm
    
    # Custom labels
    environment: production
    team: platform
    cost-center: engineering
```

## Key Insights

1. **Labels are essential** for organizing Kubernetes resources
2. **Selectors** are used by Services, Deployments, and other controllers
3. **Can't change immutable fields**, only labels and annotations
4. **Plan labeling strategy** early in project
5. **Consistent naming** makes queries easier

## Cleanup

```bash
# Delete all pods in the lab
kubectl delete pods -l app=myapp
```
