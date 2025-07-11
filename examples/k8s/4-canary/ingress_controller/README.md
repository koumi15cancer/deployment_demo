# User-Based Canary Deployment with Ingress Controller

This folder demonstrates a user-based canary deployment using Kubernetes Deployments, Services, and the NGINX Ingress controller. Traffic is routed to the canary version based on HTTP headers or cookies, using NGINX Ingress canary annotations. No service mesh is required.

---

> **Note:**
> For this demo, the kind cluster is configured to forward container port 80 to host port 8080 using a `kind-config.yaml` file. This allows you to access the Ingress controller from your local machine at `localhost:8080`. You can find the example kind config in the `setup` folder.

---

## Folder Contents
- **1-stable-deployment.yaml**: Main (stable) deployment.
- **2-canary-deployment.yaml**: Canary deployment (new version).
- **3-service.yaml**: Service for both deployments (exposes port 8181, targets 8080).
- **4-stable-ingress.yaml**: Ingress for stable traffic.
- **5-canary-ingress.yaml**: Ingress for canary traffic (user-based).

---

## How to Apply

```sh
kubectl apply -f 1-stable-deployment.yaml
kubectl apply -f 2-canary-deployment.yaml
kubectl apply -f 3-service.yaml
kubectl apply -f 4-stable-ingress.yaml
kubectl apply -f 5-canary-ingress.yaml
```

---

## How User-Based Canary Works

- **Stable Ingress** routes all traffic to the stable service by default.
- **Canary Ingress** uses NGINX Ingress annotations to route traffic to the canary service only for users with a specific header or cookie.
- You can control which users see the canary version by setting the appropriate header or cookie in their requests.

---

## Example Ingress YAML

### 4-stable-ingress.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-stable
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-v1
            port:
              number: 8181
```

### 5-canary-ingress.yaml (Cookie-Based)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-cookie: "canary"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-v2
            port:
              number: 8181
```

- To use header-based routing, replace the cookie annotation with:
  ```yaml
  nginx.ingress.kubernetes.io/canary-by-header: "X-Canary"
  nginx.ingress.kubernetes.io/canary-by-header-value: "always"
  ```

---

## Test Ingress from Your Local Machine

- **Test stable:**
  ```sh
  curl -H "Host: myapp.local" http://localhost:8080/
  ```
- **Test canary (cookie):**
  ```sh
  curl -H "Host: myapp.local" --cookie "canary=always" http://localhost:8080/
  ```
- **Test canary (header):**
  ```sh
  curl -H "Host: myapp.local" -H "X-Canary: always" http://localhost:8080/
  ```

---

## Notes
- The service is exposed on port 8181, but the container listens on port 8080.
- This approach is simple and does not require a service mesh or Flagger.
- For production, consider automation or tools like Flagger for safer rollouts. 

---

## References
- [Canary Deployments on Kubernetes without Service Mesh (Medium)](https://medium.com/@domi.stoehr/canary-deployments-on-kubernetes-without-service-mesh-425b7e4cc862) 