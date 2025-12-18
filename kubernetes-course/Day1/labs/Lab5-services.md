# Lab 5: Services and Networking

## Objective
Learn how to expose Deployments and Pods to internal and external network traffic using Services.

## Duration
~30 minutes

## Prerequisites
- Completed Lab 1-4
- Understanding of Deployments
- Basic networking concepts

## What You'll Learn
- Service concepts and types
- ClusterIP (internal networking)
- NodePort (external via host)
- LoadBalancer (external with load balancer)
- Service discovery and DNS
- Port forwarding vs Services
- Network policy basics

---

## Why Services?

Pods are ephemeral - they get new IPs when recreated. Services provide:
- ✅ Stable IP address and DNS name
- ✅ Load balancing across multiple Pods
- ✅ Network abstraction layer
- ✅ Service discovery
- ✅ Support for different traffic patterns

---

## Service Types Comparison

| Type | Access | Use Case |
|------|--------|----------|
| **ClusterIP** | Internal only | Pod-to-Pod communication |
| **NodePort** | Internal + Node IP:Port | External access via host IP |
| **LoadBalancer** | Internal + External LB | Cloud load balancer integration |
| **ExternalName** | Internal | Route to external service |

---

## Exercise Steps

### Step 1: Create a Deployment to Expose

Create file: `app-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        env:
        - name: HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
```

Deploy it:

```bash
kubectl apply -f app-deployment.yaml
kubectl get deployments
kubectl get pods -L app
```

### Step 2: Create ClusterIP Service

Create file: `service-clusterip.yaml`

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
    port: 80           # Service port
    targetPort: 80     # Pod port
    protocol: TCP
```

Deploy the service:

```bash
kubectl apply -f service-clusterip.yaml
```

### Step 3: Check ClusterIP Service

```bash
kubectl get services
```

**Notice:**
- Type: ClusterIP
- Cluster-IP: 10.x.x.x (internal only)
- Port: 80

Get detailed info:

```bash
kubectl describe service web-app-clusterip
```

Shows:
- Endpoints: List of Pod IPs the service routes to
- Port mappings

### Step 4: Test Service Discovery from Inside Cluster

Create a test Pod:

```bash
kubectl run -it test-pod --image=busybox --restart=Never -- /bin/sh
```

Inside the Pod, test DNS resolution:

```bash
# DNS resolution by service name
wget -O- web-app-clusterip
wget -O- web-app-clusterip.default.svc.cluster.local

# Using service IP
wget -O- 10.x.x.x

# Exit
exit
```

### Step 5: Port Forward to Test Service

```bash
kubectl port-forward svc/web-app-clusterip 8080:80
```

In another terminal:

```bash
curl http://localhost:8080
```

### Step 6: Create NodePort Service

Create file: `service-nodeport.yaml`

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
    port: 80           # Service port
    targetPort: 80     # Pod port
    nodePort: 30080    # Node port (30000-32767)
    protocol: TCP
```

Deploy:

```bash
kubectl apply -f service-nodeport.yaml
```

### Step 7: Check NodePort Service

```bash
kubectl get services
```

**Notice:**
- Type: NodePort
- Cluster-IP: 10.x.x.x
- PORT(S): 80:30080/TCP (internal:external)

### Step 8: Access NodePort Service

Get a node IP:

```bash
kubectl get nodes -o wide
```

Access the service:

```bash
# Using node IP and nodePort
curl http://<NODE-IP>:30080

# Example: if cluster is on 10.128.0.2
curl http://10.128.0.2:30080
```

### Step 9: Create LoadBalancer Service

Create file: `service-loadbalancer.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-loadbalancer
  labels:
    app: web-app
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
```

Deploy:

```bash
kubectl apply -f service-loadbalancer.yaml
```

**Note:** LoadBalancer type requires a cloud provider integration (AWS, GCP, Azure). On a local cluster, it may stay in Pending state.

### Step 10: Endpoints Explained

View endpoints (which Pods the service routes to):

```bash
kubectl get endpoints web-app-clusterip
```

Shows the IP addresses of running Pods.

When a Pod dies and restarts:

```bash
kubectl delete pod <pod-name>
kubectl get endpoints web-app-clusterip
# Endpoints automatically updated with new Pod IP
```

### Step 11: Multi-Port Service

Create file: `service-multiport.yaml`

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
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    protocol: TCP
```

When a service has multiple ports, you must name them.

### Step 12: Headless Service (Advanced)

For direct Pod-to-Pod communication:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-headless
spec:
  clusterIP: None  # Makes it headless
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
```

DNS returns all Pod IPs directly.

### Step 13: Service with Session Affinity

Ensure requests from same client go to same Pod:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-sticky
spec:
  selector:
    app: web-app
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
  ports:
  - port: 80
    targetPort: 80
```

### Step 14: Update Deployment, Service Auto-Routes

Delete and recreate Deployment:

```bash
kubectl delete deployment web-app
# Service still exists but has no endpoints
kubectl get endpoints web-app-clusterip

# Create new deployment
kubectl apply -f app-deployment.yaml

# Service automatically updated!
kubectl get endpoints web-app-clusterip
```

### Step 15: Cleanup

```bash
kubectl delete services web-app-clusterip web-app-nodeport web-app-loadbalancer
kubectl delete deployment web-app
```

---

## Service Manifest Best Practices

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  namespace: default
  labels:
    app: myapp
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
  - name: http          # Always name ports
    port: 80
    targetPort: http    # Can use port name or number
    protocol: TCP
  sessionAffinity: None
```

---

## DNS in Kubernetes

Service DNS name:
```
<service-name>.<namespace>.svc.cluster.local
```

Example:
```
web-app-clusterip.default.svc.cluster.local
```

You can also use:
- `web-app-clusterip` (within same namespace)
- `web-app-clusterip.default` (from different namespace)

---

## Service to Pod Routing

```
Client
  ↓
Service (Stable IP:Port)
  ↓
Endpoints (List of Pod IPs)
  ↓
Load Balancing across Pods
  ↓
Container
```

---

## Challenges

1. **Create a service with multiple ports**
   - One port for HTTP (80)
   - Another for custom app port (8080)

2. **Test service discovery**
   - Create a test pod and access service by DNS name
   - Try both short and FQDN names

3. **Monitor endpoints**
   - Scale deployment up/down
   - Watch endpoints change automatically

4. **Port forward vs NodePort**
   - Compare both methods of accessing service
   - Note the differences

---

## Key Commands

| Command | Purpose |
|---------|---------|
| `kubectl get services` | List services |
| `kubectl describe service <name>` | Service details |
| `kubectl get endpoints <name>` | Show pod endpoints |
| `kubectl port-forward svc/<name> 8080:80` | Port forward |
| `kubectl expose deployment <name> --port=80` | Create service |

---

## Network Policies (Preview)

Control traffic between Pods:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
```

This is advanced; covered in later labs.

---

## Troubleshooting

### Service has no endpoints
```bash
# Check if pods exist
kubectl get pods

# Verify selector matches
kubectl get pods -l app=web-app

# Check service selector
kubectl describe service web-app-clusterip
```

### Cannot access NodePort
```bash
# Verify service exists
kubectl get services

# Check nodePort range (30000-32767)
kubectl get service web-app-nodeport

# Verify node is accessible
ping <NODE-IP>
```

### DNS not resolving
```bash
# Test from within cluster
kubectl exec -it <pod> -- nslookup web-app-clusterip
```

---

## What's Next?

- Ingress (advanced external access routing)
- Day 2: ConfigMaps and persistent storage
- Network policies and security
- Service mesh (Istio, Linkerd)

---

## Notes

- **ClusterIP**: Default, for internal communication
- **NodePort**: For testing and small clusters
- **LoadBalancer**: Production with cloud providers
- Services decouple from Pods
- Endpoints automatically managed
- Always name multiple ports
- Use headless services for StatefulSets

