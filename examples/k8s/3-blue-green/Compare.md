# Blue-Green & Canary Deployment: Service vs Ingress vs Flagger

This document compares three common approaches for blue-green and canary deployments in Kubernetes:
- **Service-based switching**
- **Ingress controller-based switching**
- **Flagger automated progressive delivery**

---

## 1. Service-Based Blue-Green/Canary

**How it works:**
- Deploy both blue and green versions as separate Deployments.
- Use a single Service with a label selector to route traffic to either blue or green pods.
- To switch, update the Service selector.

**Pros:**
- Simple and easy to understand.
- No extra components required.
- Good for internal traffic and dev/test.

**Cons:**
- Not suitable for external/public access (unless using NodePort/LoadBalancer).
- Manual switch; no traffic splitting.
- No host/path-based routing.
- No built-in health analysis or rollback.

---

## 2. Ingress Controller-Based Blue-Green/Canary

**How it works:**
- Deploy blue and green versions, each with its own Service.
- Create an Ingress resource that routes traffic to the blue or green Service.
- To switch, edit the Ingress backend to point to the desired Service.
- Some Ingress controllers support traffic splitting for canary.

**Pros:**
- Exposes apps externally via HTTP(S).
- Supports advanced routing (host, path, etc.).
- Can support canary/traffic splitting (if controller supports).

**Cons:**
- Requires an Ingress controller to be installed and running.
- Slightly more complex than Service-only.
- Manual switch unless automated with scripts/tools.
- No built-in health analysis or rollback.

---

## 3. Flagger Automated Blue-Green/Canary

**How it works:**
- Deploy blue and green (or canary) versions as Deployments.
- Use Flagger’s Canary resource to watch for changes and automate rollout.
- Flagger works with Service Meshes (e.g., Istio) or supported Ingress controllers (e.g., NGINX, Contour).
- Flagger gradually shifts traffic, runs health checks, and can automatically rollback on failure.

**Pros:**
- Fully automated progressive delivery (blue-green, canary, A/B, etc.).
- Supports traffic splitting and gradual rollout.
- Monitors metrics and health, can rollback automatically.
- Works with both service mesh and some ingress controllers.
- Integrates with Prometheus, Grafana, etc.

**Cons:**
- Requires installing and configuring Flagger (and optionally a service mesh or compatible ingress controller).
- More moving parts and initial setup.
- Learning curve for configuration and monitoring.

---

## Summary Table

| Feature/Aspect         | Service Only      | Ingress Controller   | Flagger Automated         |
|-----------------------|-------------------|----------------------|--------------------------|
| Internal traffic      | ✔️                | ✔️                   | ✔️                       |
| External traffic      | ❌ (unless NodePort/LB) | ✔️            | ✔️ (with mesh/ingress)   |
| Routing by label      | ✔️                | ❌                   | ✔️ (via Flagger)         |
| Routing by host/path  | ❌                | ✔️                   | ✔️ (with ingress)        |
| Canary/traffic split  | ❌ Manual only     | ✔️ (if supported)    | ✔️ Automated             |
| Health checks/rollback| ❌                | ❌                   | ✔️ Automated             |
| Automation            | ❌                | ❌                   | ✔️                       |
| Simplicity            | ✔️                | ❌                   | ❌                       |
| Observability         | ❌                | ❌                   | ✔️ (metrics, dashboards) |

---

## When to Use Each Approach

- **Service Only:**
  - Internal apps, dev/test, simple environments, manual control is fine.
- **Ingress Controller:**
  - Need external access, host/path routing, or basic canary/blue-green for web apps.
- **Flagger:**
  - Production, need automation, progressive delivery, health checks, and safe rollouts.

---

## References
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Flagger Documentation](https://docs.flagger.app/)
- [Progressive Delivery](https://flagger.app/docs/intro/introduction/) 