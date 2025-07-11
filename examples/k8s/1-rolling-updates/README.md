# Rolling Updates Example

This folder demonstrates a basic Kubernetes rolling update deployment.

---

## How to Apply

> **Copy the following commands:**

```sh {copy}
kubectl apply -f 1-deployment.yaml
kubectl apply -f 3-service.yaml
```

You can copy and paste the above commands into your terminal to deploy the resources.

- `1-deployment.yaml`: Defines the rolling update deployment for the application.
- `3-service.yaml`: Exposes the deployment as a Kubernetes service.

---

## Test Network Connectivity with Curl Pod

Launch a temporary pod with curl to test network connectivity inside your cluster:

```sh {copy}
kubectl run curl --image=alpine/curl:8.2.1 -n kube-system -i --tty --rm -- sh
```

This gives you an interactive shell with curl available. The pod is removed after you exit.

---

## Repeatedly Call the Endpoint

To continuously send requests to your service (useful for testing rolling updates), run inside the curl pod shell:

```sh {copy}
for i in `seq 1 1000`; do curl myapp.default:8181/; echo ""; sleep 1; done
```

This loop sends a request every second, 1000 times, printing the response each time.

---

## Apply a New Version and Observe Rolling Update

After running the above loop, apply the new deployment to trigger a rolling update:

```sh {copy}
kubectl apply -f 1.1-deployment.yaml
```

Kubernetes will gradually replace old pods with new ones. You should see changes in the endpoint responses as new pods (with the updated version) become ready.

---

## Clean Up Existing Deployments and Pods

To start over or ensure a clean state, remove all current deployments and pods:

```sh {copy}
kubectl delete deployment --all -n default
kubectl delete pod --all -n default
```

This ensures there are no leftover resources from previous runs.

---

## Rolling Update Strategy: Percentage vs Absolute Values

A key difference between `1-deployment.yaml` and `2-deployment.yaml` is the rolling update strategy:

- **`1-deployment.yaml`** uses percentages:

  ```yaml
  maxUnavailable: 25%
  maxSurge: 25%
  ```
  Up to 25% of pods can be unavailable or extra during the update, scaling with your replica count.

- **`2-deployment.yaml`** uses absolute values:

  ```yaml
  maxUnavailable: 1
  maxSurge: 1
  ```
  Only 1 pod at a time can be unavailable or extra, regardless of the total number of replicas.

**Summary:**
- Percentages allow faster, parallel updates for large deployments.
- Absolute values provide slower, more controlled updates, minimizing risk for small or critical workloads.

---

## Monitor and Control the Rollout

Monitor and control the rollout process with these commands:

- **Check current deployments:**

  ```sh {copy}
  kubectl get deployments
  ```

- **Watch rollout status:**

  ```sh {copy}
  kubectl rollout status deployments
  ```

- **Pause the rollout:**

  ```sh {copy}
  kubectl rollout pause deployments
  ```
  Pauses the ongoing rollout, useful for investigation or to stop changes temporarily.

- **Resume the rollout:**

  ```sh {copy}
  kubectl rollout resume deployments
  ```
  Continue a paused rollout, for example if a false alarm is resolved.

- **Undo the rollout:**

  ```sh {copy}
  kubectl rollout undo deployments
  ```
  Reverts the deployment to the previous version if something goes wrong.

---

## Rolling Update Lifecycle Diagram

Below is a diagram showing the typical lifecycle of a rolling update:

```code
Rolling Update Lifecycle

   +-------------------+
   |   Start Rollout   |
   +-------------------+
             |
             v
   +---------------------------+
   |  New Deployment Applied   |
   +---------------------------+
             |
             v
   +---------------------------+
   | Pods Created (maxSurge)   |
   +---------------------------+
             |
             v
   +-------------------+
   |    Pods Ready     |
   +-------------------+
             |
             v
   +-------------------------------+
   | Old Pods Terminated           |
   |   (maxUnavailable)            |
   +-------------------------------+
             |
             v
   +-------------------+
   | Pause Rollout?    |
   +-------------------+
        |         |
      Yes        No
      |           |
+-------------------+      +-------------------+
|  Rollout Paused   |      | Continue Rollout  |
+-------------------+      +-------------------+
      |                        |
      +----------Resume--------+
             |
             v
   +-------------------+
   | Rollback Needed? 
```
