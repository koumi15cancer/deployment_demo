# Shadowing (Traffic Mirroring) Example

This example demonstrates **traffic shadowing (mirroring)** using Flagger and Istio in Kubernetes. Shadowing lets you send a copy of real user traffic to a new version of your app (canary), so you can test it under real load without affecting users.

## How It Works
- **Stable deployment (`myapp`)** serves all user traffic.
- **Canary deployment (`myapp-canary`)** is created and managed by Flagger when you update the image in the deployment manifest.
- **Shadowing:** 100% of real traffic is mirrored to the canary, but only the stable version responds to users. The canary's response is ignored.
- **Purpose:** Safely test new versions in production-like conditions before a real rollout.

```
+--------+      +-------------------+      +---------------------+
|  User  +----->| Service (myapp)   +----->| myapp (v1, stable)  |
+--------+      +-------------------+      +---------------------+
                        |
                        | (mirrored)
                        v
                +-------------------------+
                | myapp-canary (v2, test) |
                +-------------------------+
```
- All user traffic goes to the stable version.
- A copy is mirrored to the canary version for testing only.

## Key Files
- `1-namespace.yaml`: Creates the `staging` namespace with Istio injection enabled.
- `2-deployment.yaml`: Defines the stable deployment (`myapp`).
- `3-service.yaml`: Exposes the app on port 8181.
- `4-canary.yaml`: Flagger Canary resource with `mirror: true` to enable shadowing.

## How to Use
1. **Apply the manifests:**
   ```sh
   kubectl apply -f 1-namespace.yaml
   kubectl apply -f 2-deployment.yaml
   kubectl apply -f 3-service.yaml
   kubectl apply -f 4-canary.yaml
   ```
2. **Update the image in `2-deployment.yaml`** to a new version (e.g., `backend-v2:latest`).
3. **Re-apply the deployment:**
   ```sh
   kubectl apply -f 2-deployment.yaml
   ```
4. **Flagger will detect the change and create a canary deployment.**
5. **All real traffic is mirrored to the canary.**

## How to Observe
- List deployments and pods:
  ```sh
  kubectl -n staging get deployments
  kubectl -n staging get pods -o wide
  ```
- Check which image each deployment is running:
  ```sh
  kubectl -n staging get deployment myapp -o yaml | grep image
  kubectl -n staging get deployment myapp-canary -o yaml | grep image
  ```
- Describe the Flagger canary resource:
  ```sh
  kubectl -n staging describe canary myapp
  ```
- **Note:** Only the stable deployment serves user responses. The canary receives mirrored traffic for testing/monitoring only.

## Pros and Cons

**Pros:**
- Safely test new versions with real traffic before exposing to users
- Detect issues in v2 under production-like load
- No risk to user experience (only stable responses are returned)

**Cons (Key Risks):**
- **Writes:** Mirrored requests can cause duplicate writes or side effects (e.g., DB, emails) in v2. Isolate or disable writes in v2 if needed.
- **Auth:** v2 may fail mirrored requests if auth/session context is missing. Need to mock or replicate auth context.
- **Interception:** Sometimes Need ntercept/modify requests to v2 (e.g., block writes, strip sensitive data). This may require custom filters or proxies.
- **Resource Use:** v2 consumes resources even though users don’t see its responses.
- **Monitoring:** You must monitor v2 separately for errors and side effects.

## Requirements
- [Istio](https://istio.io/) (for traffic mirroring)
- [Flagger](https://flagger.app/)

## Alternative Approaches (Without Flagger)

### **NGINX Ingress (Limited)**
- **No native mirroring support**
- Can only do traffic splitting (canary) with annotations
- Would need custom NGINX config with Lua scripts or modules
- Example: Use `nginx.ingress.kubernetes.io/canary: "true"` for traffic splitting only

### **Custom Proxy Solutions**
- **Envoy Proxy:** Custom filters for request duplication
- **Custom NGINX:** `proxy_pass` with custom configuration
- **Application-level:** Custom middleware for request mirroring
- **Pros:** Full control over mirroring logic
- **Cons:** Complex setup, maintenance overhead

### **API Gateway Options**
- **Kong:** Built-in `proxy-mirror` plugin
- **Ambassador:** Native `mirror` field in mappings
- **Consul Connect:** Service mesh with mirroring capabilities
- **Pros:** Production-ready, built-in features
- **Cons:** Additional infrastructure complexity

### **Istio Native (Recommended)**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
    - myapp.example.com
  http:
    - route:
        - destination:
            host: myapp-v1
          weight: 100
      mirror:
        host: myapp-v2
      mirror_percent: 100
```

**Best for:** Simple mirroring without Flagger's automation and monitoring.

## References
- [Flagger Traffic Mirroring](https://flagger.app/docs/usage/traffic-mirroring/)
- [Istio Traffic Mirroring](https://istio.io/latest/docs/tasks/traffic-management/mirroring/) 