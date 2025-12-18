# Lab 1 Solution: Your First Pod

## Commands Used

### Create Pod
```bash
kubectl run my-nginx --image=nginx:latest --port=80
```

### Check Pod Status
```bash
kubectl get pods
```

### Get Pod Details
```bash
kubectl describe pod my-nginx
```

### View Logs
```bash
kubectl logs my-nginx
```

### Execute Commands in Pod
```bash
kubectl exec -it my-nginx -- ls -la /usr/share/nginx/html/
kubectl exec -it my-nginx -- /bin/bash
```

### Port Forward
```bash
kubectl port-forward pod/my-nginx 8080:80
```

In another terminal:
```bash
curl http://localhost:8080
```

### Delete Pod
```bash
kubectl delete pod my-nginx
```

## Key Takeaways

1. **Imperative approach** - `kubectl run` is quick for testing
2. **Pod lifecycle** - Pods are ephemeral, not persistent
3. **Port forwarding** - Useful for testing Pod connectivity
4. **Exec capability** - You can run commands inside containers

## Next Steps

- Manifest-based creation (Lab 2) is the proper way
- Use declarative approach for production
