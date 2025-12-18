# Lab 5 Solution: Services and Networking

## Service Manifests

### ClusterIP Service (Internal Only)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-clusterip
  labels:
    app: web-app
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
```

### NodePort Service (External via Node IP)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-nodeport
  labels:
    app: web-app
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - name: http
    port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
```

### LoadBalancer Service (Cloud Integration)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - name: http
    port: 80
    targetPort: 80
```

### Multi-Port Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-multiport
spec:
  selector:
    app: web-app
  type: ClusterIP
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
```

### Headless Service (Direct Pod-to-Pod)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-headless
spec:
  clusterIP: None
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
```

## Key Commands

```bash
# Create service
kubectl apply -f service-clusterip.yaml

# List services
kubectl get services
kubectl get svc

# Get detailed service info
kubectl describe service web-app-clusterip

# View endpoints (pod IPs)
kubectl get endpoints web-app-clusterip

# Port forward to service
kubectl port-forward svc/web-app-clusterip 8080:80

# Test from inside cluster
kubectl run -it test --image=busybox --restart=Never -- wget -O- web-app-clusterip

# Get service IP and ports
kubectl get svc -o wide

# Delete service
kubectl delete service web-app-clusterip
```

## Service Types Comparison

| Type | Scope | Use Case |
|------|-------|----------|
| ClusterIP | Internal Only | Pod-to-Pod communication |
| NodePort | Internal + Node IP:Port | Testing external access |
| LoadBalancer | Internal + Cloud LB | Production external access |
| ExternalName | External DNS | Route to external service |
| Headless | Internal Direct | StatefulSet apps |

## DNS Service Discovery

```bash
# Full DNS name
web-app-clusterip.default.svc.cluster.local

# Short name (same namespace)
web-app-clusterip

# Cross-namespace
web-app-clusterip.other-namespace
```

## Service Endpoints Auto-Management

```bash
# View which pods service routes to
kubectl get endpoints web-app-clusterip

# When pod dies and restarts:
# 1. Pod gets new IP
# 2. Endpoints automatically updated
# 3. Service routes to new IP
# Zero configuration needed!
```

## Practical Workflow

```bash
# 1. Create deployment
kubectl apply -f app-deployment.yaml

# 2. Create service
kubectl apply -f service-clusterip.yaml

# 3. Check service
kubectl get services
kubectl describe service web-app-clusterip

# 4. View endpoints
kubectl get endpoints web-app-clusterip

# 5. Test connectivity
kubectl port-forward svc/web-app-clusterip 8080:80

# In another terminal:
# curl http://localhost:8080

# 6. Test from within cluster
kubectl run -it test --image=busybox --restart=Never -- /bin/sh
# Inside: wget -O- http://web-app-clusterip

# 7. Clean up
kubectl delete service web-app-clusterip
kubectl delete deployment web-app
```

## Session Affinity (Sticky Sessions)

```yaml
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```

Ensures requests from same client go to same pod.

## Service Creation Methods

### Imperative (Quick)
```bash
kubectl expose deployment web-app --port=80 --type=ClusterIP
```

### Declarative (Recommended)
```bash
kubectl apply -f service.yaml
```

## Troubleshooting

```bash
# Service has no endpoints
kubectl get endpoints web-app-clusterip
kubectl get pods -l app=web-app

# Cannot access service
kubectl describe service web-app-clusterip

# Check service selector matches pods
kubectl get pods --show-labels

# Test DNS from pod
kubectl exec -it <pod> -- nslookup web-app-clusterip

# Check service exists
kubectl get svc

# Verify pod is healthy
kubectl get pods -o wide
```

## Key Insights

1. **Services decouple from Pods** - Use labels for routing
2. **Endpoints auto-managed** - No manual configuration
3. **Multiple access methods** - ClusterIP, NodePort, LoadBalancer
4. **DNS built-in** - Access by service name
5. **Load balancing automatic** - Round-robin by default
6. **Port mapping flexible** - Can map any port to any container port

## Next Steps

- Ingress (advanced HTTP routing)
- Network policies (security)
- Service mesh (Istio, Linkerd)
- DNS troubleshooting advanced topics
