# Lab 1: Your First Pod

## Objective
Create and run your first Kubernetes Pod using the imperative approach with `kubectl run` command.

## Duration
~15 minutes

## Prerequisites
- kubectl configured and connected to cluster (run `setup.sh`)
- Basic understanding of containers

## What You'll Learn
- Creating Pods imperatively
- Viewing Pod information
- Accessing Pod logs
- Executing commands in a Pod
- Deleting Pods

---

## Exercise Steps

### Step 1: Create Your First Pod

Create a simple Pod running nginx:

```bash
kubectl run my-nginx --image=nginx:latest --port=80
```

**What this does:**
- Creates a Pod named `my-nginx`
- Uses nginx image (latest version)
- Exposes port 80

### Step 2: Verify Pod Creation

Check if your Pod is running:

```bash
kubectl get pods
```

**Expected output:**
```
NAME       READY   STATUS    RESTARTS   AGE
my-nginx   1/1     Running   0          20s
```

### Step 3: Get Detailed Pod Information

```bash
kubectl describe pod my-nginx
```

**Look for:**
- Pod name and namespace
- Status (Running, Pending, etc.)
- Container image
- IP address assigned
- Events at the bottom

### Step 4: View Pod Logs

```bash
kubectl logs my-nginx
```

**Note:** Since nginx starts successfully, you might see minimal logs initially.

### Step 5: Execute Command Inside Pod

List files in the running Pod:

```bash
kubectl exec -it my-nginx -- ls -la /usr/share/nginx/html/
```

**Breakdown:**
- `exec`: Execute a command in the container
- `-it`: Interactive and allocate terminal
- `--`: Separator before the actual command
- `ls -la`: List files in nginx default directory

### Step 6: Access Pod Shell

Get an interactive shell in the Pod:

```bash
kubectl exec -it my-nginx -- /bin/bash
```

Inside the shell, you can:
```bash
# Check nginx version
nginx -v

# View nginx config
cat /etc/nginx/nginx.conf

# Check running processes
ps aux

# Exit shell
exit
```

### Step 7: Get Pod IP Address

```bash
kubectl get pod my-nginx -o wide
```

This shows the internal IP address of your Pod.

### Step 8: Port Forward to Access Pod

Forward local port to Pod:

```bash
kubectl port-forward pod/my-nginx 8080:80
```

**In another terminal**, test it:
```bash
curl http://localhost:8080
```

You should see the nginx welcome page HTML.

### Step 9: Check Pod Events and Logs

```bash
# Get events in default namespace
kubectl get events

# See logs with follow option
kubectl logs -f my-nginx
```

Press `Ctrl+C` to stop following logs.

### Step 10: Delete the Pod

```bash
kubectl delete pod my-nginx
```

**Verify deletion:**
```bash
kubectl get pods
```

---

## Key Commands Summary

| Command | Purpose |
|---------|---------|
| `kubectl run <name> --image=<image>` | Create Pod imperatively |
| `kubectl get pods` | List all Pods |
| `kubectl describe pod <name>` | Detailed Pod info |
| `kubectl logs <name>` | View Pod logs |
| `kubectl exec -it <name> -- <cmd>` | Execute command in Pod |
| `kubectl port-forward pod/<name> 8080:80` | Forward ports |
| `kubectl delete pod <name>` | Delete Pod |

---

## Challenges (Optional)

1. **Create multiple Pods**: Run the same command 3 times with different pod names
   ```bash
   kubectl run pod-1 --image=nginx
   kubectl run pod-2 --image=nginx
   kubectl run pod-3 --image=nginx
   ```
   
2. **Different Images**: Try creating Pods with different images
   ```bash
   kubectl run alpine-pod --image=alpine
   kubectl run busybox-pod --image=busybox
   ```

3. **Check Status**: Keep running `kubectl get pods` to see status changes
   - Notice the READY, STATUS columns
   - Check AGE to see how long it's been running

4. **Resource Limits**: Create a Pod with resource requests
   ```bash
   kubectl run nginx-limited --image=nginx --requests=memory=64Mi,cpu=100m --limits=memory=128Mi,cpu=200m
   ```

---

## Troubleshooting

### Pod stays in Pending/ContainerCreating
```bash
# Check events for errors
kubectl describe pod my-nginx

# Check node resources
kubectl top nodes
```

### ImagePullBackOff Error
```bash
# Image might not exist or be inaccessible
# Use 'describe' to see the exact error
kubectl describe pod my-nginx

# Try with a different image tag
kubectl run test --image=nginx:1.21
```

### Connection Refused in Port Forward
```bash
# Make sure port-forward is still running
# Start it again if needed
kubectl port-forward pod/my-nginx 8080:80

# Try in a new terminal
curl http://localhost:8080
```

---

## What's Next?

Once you've completed this lab:
- Move to **Lab 2**: Learn declarative Pod creation with YAML manifests
- This is the imperative approach; Lab 2 shows the recommended IaC approach

---

## Notes

- Pods are ephemeral - they're meant to be created and destroyed
- Always use higher-level objects (Deployments) for production
- The imperative approach is good for learning and quick testing
- Manifest-based (declarative) approach is better for reproducibility

---

## Solution

See `../solutions/lab1-solution.yaml` for a manifest version of what you created today.
