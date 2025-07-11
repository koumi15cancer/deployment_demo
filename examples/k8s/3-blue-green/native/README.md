# Blue-Green Deployment Example

This folder demonstrates a basic Kubernetes **Blue-Green Deployment** using two separate deployments (blue and green) and a service switch.

---

## How to Apply

> **Copy the following commands:**

```sh {copy}
kubectl apply -f 1-blue-deployment.yaml
kubectl apply -f 3-service.yaml
```

- `1-blue-deployment.yaml`: Deploys the initial (blue) version of the application.
- `3-service.yaml`: Exposes the blue deployment as a Kubernetes service.

---

## Test Network Connectivity with Curl Pod

To test from inside the cluster, launch a temporary pod with curl:

```sh
kubectl run curl --image=alpine/curl:8.2.1 -n kube-system -i --tty --rm -- sh
```

Then, inside the pod shell, run:

```sh
for i in `seq 1 1000`; do curl myapp.default:8080/; echo ""; sleep 1; done
```

This will send repeated requests to your service from within the cluster.

---

## Deploy the Green Version

Apply the green deployment (new version) alongside the blue deployment:

```sh {copy}
kubectl apply -f 2-green-deployment.yaml
```

The green deployment will be running, but the service still points to blue.

---

## Switch Service to Green

Edit the service to point to the green deployment by changing the selector:

```yaml
selector:
  app: myapp
  replica: green
```

Apply the updated service:

```sh {copy}
kubectl apply -f 3-service.yaml
```

Now, the service routes traffic to the green deployment. You should see the new version's responses.

---

## Clean Up Existing Deployments and Pods

To start over or ensure a clean state, remove all current deployments and pods:

```sh {copy}
kubectl delete deployment --all -n default
kubectl delete pod --all -n default
```

---

## Blue-Green Deployment Lifecycle Diagram

Below is a block diagram showing the typical lifecycle of a Blue-Green deployment:

```
+-----------------------------+
|  Start Blue-Green Deployment|
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
|  Test Green Version         |
+-----------------------------+
            |
            v
+-----------------------------+
|  Switch Service to Green?   |
+-----------------------------+
      |             |
     Yes           No
      |             |
+---------------------+   +---------------------+
| Service -> Green    |   | Rollback to Blue    |
+---------------------+   +---------------------+
      |
      v
+-----------------------------+
| Remove Blue (Optional)      |
+-----------------------------+
```

---

## When to Use Blue-Green Deployments

- When you need zero-downtime deployments and easy rollback.
- When you want to test the new version before switching traffic.
- For production environments where reliability is critical.

**Note:** Blue-Green deployments require enough resources to run both versions simultaneously. 