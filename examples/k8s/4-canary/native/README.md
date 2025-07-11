# Native Canary Deployment (Manual Weight-Based Traffic Management)

> **Highlight:**
> This approach uses **weight-based traffic management**. Traffic is split between the main and canary versions by adjusting the number of pod replicas for each deployment. The more replicas a version has, the more traffic it receives.

This folder demonstrates a native canary deployment using Kubernetes Deployments and Services, with traffic management handled by manually adjusting the number of replicas for the main and canary deployments. No service mesh or Flagger is required.

---

> **Note:**
> For this demo, the kind cluster is configured to forward container port 80 to host port 8080 using a `kind-config.yaml` file. This allows you to access the Ingress controller from your local machine at `localhost:8080`. You can find the example kind config in the `setup` folder.

---

## Folder Contents
- **1-deployment.yaml**: Main (stable) deployment.
- **2-canary-deployment.yaml**: Canary deployment (new version).
- **3-service.yaml**: Service for both deployments (exposes port 8181, targets 8080).

---

## How to Apply

```sh
kubectl apply -f 1-deployment.yaml
kubectl apply -f 2-canary-deployment.yaml
kubectl apply -f 3-service.yaml
```

---

## How the Flow Works

1. **Deploy main (stable) version** and expose via Service and Ingress.
2. **Deploy canary version** (new version) alongside the main deployment.
3. **Manually adjust replicas** to control traffic weights:
   - Increase canary replicas to shift more traffic to the canary version.
   - Decrease main replicas to shift less traffic to the stable version.
4. **Monitor traffic and app health.**
5. **Promote canary** by scaling up canary and scaling down (or deleting) the main deployment.

---

## Example Weight-Based Traffic Management

- 90% stable, 10% canary:
  - Main deployment: 9 replicas
  - Canary deployment: 1 replica
- 50/50 split:
  - Main deployment: 5 replicas
  - Canary deployment: 5 replicas
- 100% canary:
  - Main deployment: 0 replicas
  - Canary deployment: 10 replicas

---

## Test Ingress from Your Local Machine

Once the Ingress controller is running and your Ingress resource is applied, you can test access from your local machine with:

```sh
curl -H "Host: myapp.local" http://localhost:8080/
```

- Replace `myapp.local` with the host defined in your Ingress resource if different.

---

## Canary Flow Diagram

```
+-----------------------------+
|  Start Native Canary        |
+-----------------------------+
            |
            v
+-----------------------------+
|  Deploy Stable (Current)    |
+-----------------------------+
            |
            v
+-----------------------------+
|  Deploy Canary (New)        |
+-----------------------------+
            |
            v
+-----------------------------+
|  Manually Adjust Replicas   |
|  (Weight-Based Traffic)     |
+-----------------------------+
            |
            v
+-----------------------------+
|  Promote or Rollback?       |
+-----------------------------+
      |             |
     Promote       Rollback
      |             |
+---------------------+   +---------------------+
| Scale up Canary     |   | Keep Stable Live    |
+---------------------+   +---------------------+
      |
      v
+-----------------------------+
| Remove Old (Optional)       |
+-----------------------------+
```

---

## CLI Tips
- **Scale deployments to shift traffic:**
  ```sh
  kubectl scale deployment main-app --replicas=5
  kubectl scale deployment canary-app --replicas=5
  ```
- **Check Ingress:**
  ```sh
  kubectl get ingress
  kubectl describe ingress myapp-ingress
  ```
- **Test access (from your machine):**
  ```sh
  curl -H "Host: myapp.local" http://localhost:8080/
  ```
- **Test from inside the cluster:**
  ```sh
  kubectl run curl --image=alpine/curl:8.2.1 -i --tty --rm -- sh
  # Inside pod:
  curl myapp.default:8181/
  ```

---

## Notes
- **Traffic is split between main and canary by adjusting the number of pod replicas for each deployment (weight-based traffic).**
- The service is exposed on port 8181, but the container listens on port 8080.
- This approach is simple and does not require a service mesh or Flagger. 