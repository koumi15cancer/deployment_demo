# Recreate Strategy Example

This folder demonstrates a basic Kubernetes deployment using the **Recreate** strategy.

---

## How to Apply

> **Copy the following commands:**

```sh {copy}
kubectl apply -f 1-deployment.yaml
```

You can copy and paste the above command into your terminal to deploy the resources.

- `1-deployment.yaml`: Defines the deployment for the application using the Recreate strategy.

---

## Test Network Connectivity with Curl Pod

Launch a temporary pod with curl to test network connectivity inside your cluster:

```sh {copy}
kubectl run curl --image=alpine/curl:8.2.1 -n kube-system -i --tty --rm -- sh
```

This gives you an interactive shell with curl available. The pod is removed after you exit.

---

## Repeatedly Call the Endpoint

To continuously send requests to your service (useful for testing deployment changes), run inside the curl pod shell:

```sh {copy}
for i in `seq 1 1000`; do curl myapp.default:8080/; echo ""; sleep 1; done
```

This loop sends a request every second, 1000 times, printing the response each time.

---

## Apply a New Version and Observe Recreate Behavior

After running the above loop, apply the new deployment to trigger the Recreate strategy:

```sh {copy}
kubectl apply -f 2-deployment.yaml
```

Kubernetes will **terminate all old pods before creating new ones**. You may see a short downtime as the new pods start up.

---

## Clean Up Existing Deployments and Pods

To start over or ensure a clean state, remove all current deployments and pods:

```sh {copy}
kubectl delete deployment --all -n default
kubectl delete pod --all -n default
```

This ensures there are no leftover resources from previous runs.

---

## Recreate Strategy: How It Works

With the **Recreate** strategy, when you update a deployment:
- **All existing pods are terminated first.**
- **New pods are created only after the old ones are gone.**
- This can cause a brief period of downtime, as there are no running pods during the transition.

This strategy is simple and sometimes necessary (e.g., when old and new versions cannot run at the same time), but it is not suitable for highly available applications.

---

## Recreate Deployment Lifecycle Diagram

Below is a block diagram showing the typical lifecycle of a Recreate deployment:

```
+-----------------------+
|    Start Rollout      |
+-----------------------+
            |
            v
+---------------------------+
|  New Deployment Applied   |
+---------------------------+
            |
            v
+---------------------------+
| All Old Pods Terminated   |
+---------------------------+
            |
            v
+-----------------------+
|   New Pods Created    |
+-----------------------+
            |
            v
+-----------------------+
|      Pods Ready       |
+-----------------------+
            |
            v
+-----------------------+
|  Rollback Needed?     |
+-----------------------+
      |           |
     Yes          No
      |           |
+-----------------------+   +-----------------------+
|Rollback: Recreate Old |   | Deployment Complete   |
|        Pods           |   +-----------------------+
+-----------------------+
```

---

## When to Use Recreate

- When your application cannot have multiple versions running at the same time (e.g., stateful apps, DB migrations).
- When a short downtime is acceptable.
- For simple or development/test environments.

**Note:** For production and high-availability, prefer RollingUpdate or other advanced strategies. 