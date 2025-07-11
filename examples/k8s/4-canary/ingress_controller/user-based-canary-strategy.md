# User-Based Canary Strategy: Practical Guide

This document summarizes how to safely roll out a new version to specific users using user-based canary (header/cookie targeting) in Kubernetes with NGINX Ingress.

---

## 1. Targeting Specific Users
- **Header/Cookie-based routing:**
  - Use NGINX Ingress canary annotations to route requests with a specific header or cookie to the canary version.
  - Example: Only users with `canary=always` cookie or `X-Canary: always` header see the canary.
- **How to assign:**
  - **Manual:** Testers/beta users set the cookie/header themselves (browser, curl, Postman).
  - **Automated:**
    - App logic, API gateway, or sidecar injects the header/cookie for selected users (e.g., by user ID, group, or feature flag).

---

## 2. Workflow for Safe Canary Rollout

1. **Deploy canary version (v2) alongside stable (v1).**
2. **Create canary Ingress with header/cookie annotation.**
3. **Assign a small group of users to canary (via cookie/header).**
4. **Monitor metrics and logs for both versions.**
5. **If healthy, expand canary group or switch to weight-based (e.g., 10% of all users).**
6. **If still healthy, promote canary to stable (scale up v2, scale down v1, or update Ingress).**
7. **If issues, rollback by routing all traffic to v1.**


## 5. Summary Table

| Step                | What to do?                                   | How to monitor?                |
|---------------------|-----------------------------------------------|-------------------------------|
| Deploy canary       | Deploy v2, set up canary Ingress              | Pod health, readiness         |
| Target users        | Assign header/cookie to select users          | Log user IDs, request headers |
| Monitor             | Track errors, latency, business KPIs          | Prometheus, Grafana, logs     |
| Expand/rollback     | Increase group or revert if issues            | Alerting, dashboards          |
| Promote             | Route all traffic to v2, deprecate v1         | Confirm stability             |

---

## 6. Key Takeaways
- Use header/cookie-based canary for targeted user rollout.
- Assign users via app logic, API gateway, or sidecar.
- Monitor closely, automate rollback/promotion, and expand traffic only when metrics are healthy. 

---

## Canary via Infrastructure vs. Codebase: Discussion

### **Infrastructure-Based Canary (Ingress, API Gateway, Service Mesh)**
- **How it works:**
  - Traffic routing is handled outside the application, using Ingress annotations, API gateway rules, or service mesh policies.
  - Examples: NGINX Ingress canary annotations, Istio traffic splitting, API gateway header/cookie routing.
- **Pros:**
  - No code changes required for basic routing.
  - Centralized control and observability.
  - Easy to roll back or adjust traffic split quickly.
  - Works for any language or app stack.
- **Cons:**
  - Limited to what the infrastructure can inspect (headers, cookies, IP, etc.).
  - Complex user targeting (e.g., by user ID) may require extra logic (sidecar, gateway plugin).
  - Harder to do fine-grained feature toggling or business logic-based canary.

### **Codebase-Based Canary (Feature Flags, App Logic)**
- **How it works:**
  - The application itself decides which users see new features or versions, often using feature flag libraries or custom logic.
  - Examples: LaunchDarkly, Unleash, homegrown feature flag systems.
- **Pros:**
  - Fine-grained, business-aware targeting (user ID, account, geography, etc.).
  - Can toggle features at runtime, not just at deployment boundaries.
  - Enables A/B testing, gradual rollout, and experimentation.
- **Cons:**
  - Requires code changes and deployments to add new flags.
  - More moving parts in the app (risk of flag mismanagement).
  - Rollback may require code redeploy or flag system reliability.

### **Comparison Table**

| Approach         | Pros                                      | Cons                                      | Use When...                       |
|-----------------|-------------------------------------------|-------------------------------------------|-----------------------------------|
| Infra-based     | No code change, fast rollback, centralized| Limited targeting, less business context  | Simple canary, infra-driven teams |
| Codebase-based  | Fine-grained, business-aware, A/B, runtime| Code changes, more app complexity         | Product-driven, A/B, experiments  |

### **Practical Guidance**
- **Start with infra-based canary** for simple, fast rollouts and when you want to test new versions with a small group (e.g., header/cookie-based).
- **Use codebase-based canary/feature flags** for advanced targeting, A/B testing, or when product/business logic determines rollout.
- **Combine both:** Use infra for initial rollout, then feature flags for deeper experimentation and gradual enablement. 

### Team Familiarity: Codebase vs. Infrastructure

When choosing a canary strategy, consider team's strengths and ecosystem:

- **Familiar with codebase/business logic:**
  - Confident with code changes and feature flags
  - Can target users precisely and experiment safely
  - Best for teams owning the app and its logic

- **Less familiar with codebase (e.g., SRE/DevOps/platform teams):**
  - Prefer infra-based rollout (Ingress, service mesh)
  - No need to touch app code; safer for unknown/legacy systems
  - Useful for third-party or black-box apps

- **Hybrid:**
  - Start with infra-based rollout, then use feature flags for finer control
  - Collaboration between app and platform teams maximizes safety and agility

## References

- [Canary Deployments with NGINX Ingress Controller (Medium)](https://medium.com/google-cloud/canary-deployments-with-kubernetes-and-ingress-nginx-8b5a7753b36b)
- [NGINX Ingress Controller Canary Documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#canary)
- [Feature Toggles (Martin Fowler)](https://martinfowler.com/articles/feature-toggles.html) 