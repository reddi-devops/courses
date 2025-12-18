# Day 1: Kubernetes Fundamentals & Getting Started

## 🎯 Learning Objectives

By the end of Day 1, you will:
- Understand core Kubernetes concepts (Pods, Deployments, Services)
- Set up kubectl and connect to your cluster (10.128.0.2)
- Create and manage your first Pod
- Expose a Pod using a Service
- Work with basic kubectl commands
- Deploy an application using a Deployment

---

## 📚 Core Concepts Overview

### 1. **Kubernetes Architecture**
- **Cluster**: A set of nodes managed by a control plane
- **Master/Control Plane**: Manages the cluster state
- **Worker Nodes**: Run containerized applications
- **API Server**: Entry point for all cluster operations

### 2. **Basic Kubernetes Objects**

#### Pod
- Smallest deployable unit in Kubernetes
- Wraps one or more containers
- Containers in a Pod share network namespace
- Usually created as part of a Deployment

#### Deployment
- Higher-level abstraction over Pods
- Manages ReplicaSets for scaling and rolling updates
- Ensures desired number of replicas are always running
- Declarative updates for Pods and ReplicaSets

#### Service
- Exposes Pods to network traffic (internal/external)
- Provides stable IP address and DNS name
- Load balances traffic across multiple Pods
- Types: ClusterIP, NodePort, LoadBalancer

#### Namespace
- Virtual cluster within a physical cluster
- Isolates resources and teams
- Default namespace: `default`

---

## ✅ Prerequisites

- kubectl installed and working
- Access to Kubernetes cluster at `10.128.0.2`
- Basic Docker knowledge (understanding of containers)
- Text editor (vim, nano, or VS Code)

---

## 🚀 Getting Started

### Step 1: Configure kubectl Access

Run the setup script to configure kubectl:
```bash
bash setup.sh 10.128.0.2
```

This will:
- Set up cluster context
- Verify cluster connectivity
- Check node availability

### Step 2: Verify Cluster Access

```bash
# Check cluster info
kubectl cluster-info

# List all nodes
kubectl get nodes

# List all namespaces
kubectl get namespaces

# Get pod information in default namespace
kubectl get pods
```

---

## 📋 Lab Exercises

Complete the following hands-on exercises in order:

### Lab 1: First Pod (Basic)
**File**: `labs/Lab1-first-pod.md`

Create and run your first Pod using a simple nginx container.

**Key Commands**:
- `kubectl run`
- `kubectl get pods`
- `kubectl describe pod`
- `kubectl logs pod`
- `kubectl exec`

---

### Lab 2: Pod Manifest (IaC)
**File**: `labs/Lab2-pod-manifest.md`

Create a Pod using YAML manifest (Infrastructure as Code approach).

**Key Concepts**:
- YAML structure
- Pod specification
- Resource requests/limits

---

### Lab 3: Managing Pods
**File**: `labs/Lab3-managing-pods.md`

Learn how to manage multiple Pods, update, and delete them.

**Key Operations**:
- Create multiple Pods
- Update Pod properties
- Delete Pods
- Use selectors and labels

---

### Lab 4: Introduction to Deployments
**File**: `labs/Lab4-deployments.md`

Create a Deployment for managing multiple Pod replicas.

**Key Concepts**:
- Replica management
- Rolling updates
- Self-healing
- Scaling

---

### Lab 5: Services and Networking
**File**: `labs/Lab5-services.md`

Expose your Deployment using different Service types.

**Key Concepts**:
- ClusterIP (internal)
- NodePort (external via host)
- Service discovery
- Load balancing

---

## 📖 Essential kubectl Commands

```bash
# Cluster Information
kubectl cluster-info                    # Display cluster info
kubectl version                         # Show client/server versions
kubectl get nodes                       # List all nodes

# Pod Operations
kubectl get pods                        # List Pods
kubectl describe pod <pod-name>        # Detailed Pod info
kubectl logs <pod-name>                # View Pod logs
kubectl exec -it <pod-name> -- /bin/sh # Access Pod shell
kubectl delete pod <pod-name>          # Delete a Pod

# Deployment Operations
kubectl create deployment <name> --image=<image> # Create deployment
kubectl get deployments                 # List deployments
kubectl scale deployment <name> --replicas=3    # Scale deployment
kubectl rollout status deployment/<name>        # Check rollout status
kubectl delete deployment <name>        # Delete deployment

# Service Operations
kubectl get services                    # List services
kubectl describe service <service-name> # Service details
kubectl port-forward svc/<svc-name> 8080:80   # Port forwarding

# Debugging
kubectl get events                      # View cluster events
kubectl top nodes                       # Node resource usage
kubectl describe node <node-name>       # Node detailed info
```

---

## 📁 Directory Structure

```
Day1/
├── README.md              # This file
├── setup.sh              # Cluster configuration script
├── labs/
│   ├── Lab1-first-pod.md
│   ├── Lab2-pod-manifest.md
│   ├── Lab3-managing-pods.md
│   ├── Lab4-deployments.md
│   └── Lab5-services.md
├── manifests/            # YAML files for reference
│   ├── simple-pod.yaml
│   ├── nginx-deployment.yaml
│   ├── service-clusterip.yaml
│   ├── service-nodeport.yaml
│   └── multi-container-pod.yaml
└── solutions/            # Sample solutions
    ├── lab1-solution.yaml
    ├── lab2-solution.yaml
    ├── lab3-solution.yaml
    ├── lab4-solution.yaml
    └── lab5-solution.yaml
```

---

## 🎓 Learning Path

1. **Understand the concepts** (Read README sections)
2. **Setup your environment** (Run setup.sh)
3. **Complete Lab 1-5 in order** (Each builds on previous knowledge)
4. **Refer to manifests/** for examples
5. **Check solutions/** if stuck (but try first!)
6. **Document your learnings** (Keep notes)

---

## 🔗 Useful Resources

- [Official Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Interactive Kubernetes Tutorial](https://kubernetes.io/docs/tutorials/)

---

## 💡 Pro Tips

1. **Always use manifests**: Production-ready configuration
2. **Use labels and selectors**: Organize and query resources
3. **Check logs often**: `kubectl logs` is your friend
4. **Use namespaces**: Isolate resources and teams
5. **Start small**: Master basics before advanced features
6. **Practice repeatedly**: Kubernetes concepts require hands-on experience

---

## ❓ Troubleshooting

### Cluster Connection Failed
```bash
# Check if cluster is accessible
ping 10.128.0.2

# Verify kubectl configuration
kubectl config view

# Reset connection
bash setup.sh 10.128.0.2
```

### Pod CrashLoopBackOff
```bash
# Check logs for errors
kubectl logs <pod-name>

# Describe pod for events
kubectl describe pod <pod-name>

# Check resource limits/requests
```

### Service Not Accessible
```bash
# Check service endpoints
kubectl get endpoints <service-name>

# Verify pod is running
kubectl get pods -l app=<label>

# Test connectivity
kubectl exec -it <pod-name> -- curl localhost:8080
```

---

## ✨ What's Next?

After completing Day 1, you'll be ready for:
- Day 2: Persistent Storage & ConfigMaps
- Day 3: Resource Management & Namespaces
- Day 4: Security & RBAC
- ... and more in your 30-day learning plan

---

Happy Learning! 🚀
