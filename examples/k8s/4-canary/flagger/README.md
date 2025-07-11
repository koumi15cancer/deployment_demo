# Canary Deployment with Flagger

This folder demonstrates a canary deployment using Flagger, Kubernetes Deployments, Services, and an Ingress controller (e.g., NGINX Ingress). No service mesh is required.

---

> **Note:**
> For this demo, the kind cluster is configured to forward container port 80 to host port 8080 using a `kind-config.yaml` file. This allows you to access the Ingress controller from your local machine at `localhost:8080`. You can find the example kind config in the `setup` folder.

---

## Folder Contents
- **1-namespace.yaml**: Namespace for the canary deployment.
- **2-deployment.yaml**: Deploys the application (canary-enabled).
- **3-service.yaml**: Service for the deployment (exposes port 8181, targets 8080).
- **4-canary.yaml**: Flagger Canary resource for automated rollout.

---

## How to Apply

```sh
kubectl apply -f 1-namespace.yaml
kubectl apply -f 2-deployment.yaml
kubectl apply -f 3-service.yaml
kubectl apply -f 4-canary.yaml
```

---

## How the Flow Works

1. **Deploy application** and expose via Service and Ingress.
2. **Flagger** manages the canary rollout and traffic shifting between stable and canary versions.
3. **Test canary** (internally or by monitoring Flagger's progress).
4. **Flagger promotes** the canary to stable after checks pass.
5. **Optionally remove old version** after confirming canary is healthy.

---

## Canary Flow Diagram

```
+-----------------------------+
|  Start Canary Rollout       |
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
|  Flagger Shifts Traffic     |
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
| Service -> Canary   |   | Keep Stable Live    |
+---------------------+   +---------------------+
      |
      v
+-----------------------------+
| Remove Old (Optional)       |
+-----------------------------+
```

---

## CLI Tips
- **Check Flagger Canary status:**
  ```sh
  kubectl -n <namespace> get canary
  kubectl -n <namespace> describe canary <name>
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
- The service is exposed on port 8181, but the container listens on port 8080.
- This approach is simple and does not require a service mesh.
- For production, consider automation or tools like Flagger for safer rollouts. 