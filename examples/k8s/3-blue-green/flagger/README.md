# Blue-Green Deployment with Flagger (Staging Namespace)

This folder demonstrates a **blue-green deployment** using [Flagger](https://flagger.app/) and Istio in the `staging` namespace. Flagger automates the analysis and promotion of new versions, ensuring safe and observable releases.

---

**About the Tools:**
- **Istio**: Handles advanced traffic routing, letting us control which version (blue or green) receives user requests without changing app code.
- **Flagger**: Watches for new app versions, runs automated tests, and safely switches traffic from blue to green only if the new version passes health checks.

---

## Folder Contents
- **1-namespace.yaml**: Creates the `staging` namespace for isolation.
- **2-deployment.yaml**: The app Deployment managed by Flagger (update this to trigger a rollout).
- **3-service.yaml**: Exposes the app as a Kubernetes Service (used by Flagger for traffic switching).
- **4-blue-green.yaml**: The Flagger Canary resource that automates blue-green analysis and promotion.

---

## How to Apply

> **Copy the following commands:**

```sh
kubectl apply -f 1-namespace.yaml
kubectl apply -n staging -f 2-deployment.yaml
kubectl apply -n staging -f 3-service.yaml
kubectl apply -n staging -f 4-blue-green.yaml
```

- All resources are deployed in the `staging` namespace for safe testing.

---

## How the Flow Works

1. **Initial Deploy:**
   - Deploy the app and service in `staging`.
   - Flagger starts monitoring the deployment.
2. **Update the Deployment:**
   - Change the image tag or spec in `2-deployment.yaml` and re-apply.
   - Flagger detects the change and starts a blue-green rollout.
3. **Analysis Phase:**
   - Flagger deploys the new version (green) alongside the old (blue).
   - It runs analysis checks (success rate, latency, custom webhooks) for several intervals.
   - During this phase, only test traffic (not real users) is sent to green.
4. **Promotion or Rollback:**
   - If all checks pass, Flagger switches the service to green (all traffic goes to the new version).
   - If checks fail, Flagger rolls back to blue (no user traffic goes to green).

---

## Blue-Green Flow Diagram

```
+-----------------------------+
|  Start Blue-Green Rollout   |
+-----------------------------+
            |
            v
+-----------------------------+
|  Deploy Blue (Current)      |
+-----------------------------+
            |
            v
+-----------------------------+
|  Deploy Green (New)         |
+-----------------------------+
            |
            v
+-----------------------------+
|  Flagger Analysis Phase     |
|  (test traffic only)        |
+-----------------------------+
            |
            v
+-----------------------------+
|  All Checks Pass?           |
+-----------------------------+
      |             |
     Yes           No
      |             |
+---------------------+   +---------------------+
| Switch to Green     |   | Rollback to Blue    |
| (all traffic)       |   | (keep blue live)    |
+---------------------+   +---------------------+
      |
      v
+-----------------------------+
| Remove Blue (Optional)      |
+-----------------------------+
```

---

## Check Flagger Logs and Status

To monitor Flagger’s progress and debug issues, use these commands:

- **Watch Flagger logs:**
  ```sh
  kubectl -n istio-system logs deployment/flagger -f
  ```
- **Check canary status:**
  ```sh
  kubectl -n staging get canaries
  kubectl -n staging describe canary myapp
  ```

---

## Clean Up

To remove all resources from the `staging` namespace:

```sh
kubectl delete namespace staging
```

---

## References & Further Reading
- [Istio Documentation](https://istio.io/latest/docs/)
- [Flagger Documentation](https://docs.flagger.app/)
- [Progressive Delivery Concepts](https://flagger.app/docs/intro/introduction/)
- [Blue-Green Deployment Pattern](https://martinfowler.com/bliki/BlueGreenDeployment.html)

---

## Notes
- This example is isolated to the `staging` namespace for safe testing.
- Requires Istio and Flagger to be installed (see `../setup/README.md`).
- For production, adapt the namespace and analysis settings as needed. 