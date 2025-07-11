# Blue-Green Deployment with Ingress Controller

This folder demonstrates a simple blue-green deployment using only Kubernetes Deployments, Services, and an Ingress controller (e.g., NGINX Ingress). No service mesh is required.

---

## Folder Contents
- **1-blue-deployment.yaml**: Deploys the blue (current) version.
- **2-green-deployment.yaml**: Deploys the green (new) version.
- **3-blue-service.yaml**: Service for the blue deployment.
- **4-green-service.yaml**: Service for the green deployment.
- **5-ingress.yaml**: Ingress resource that routes external traffic to the blue or green service.

---

## How to Apply

```sh
kubectl apply -f 1-blue-deployment.yaml
kubectl apply -f 2-green-deployment.yaml
kubectl apply -f 3-blue-service.yaml
kubectl apply -f 4-green-service.yaml
kubectl apply -f 5-ingress.yaml
```

---

> **Note:**
> For this demo, the kind cluster is configured to forward container port 80 to host port 8080 using a `kind-config.yaml` file. This allows you to access the Ingress controller from your local machine at `localhost:8080`. You can find the example kind config in the `setup` folder.

## Installing Ingress NGINX Controller on kind

Before applying your Ingress resources, you need to install the ingress-nginx controller. For kind clusters, use the following command:

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/kind/deploy.yaml
```

**Important:** The ingress-nginx controller pod will only be scheduled on nodes labeled with `ingress-ready=true`. For kind, label your control-plane node (replace `demo-control-plane` with your node name if different):

```sh
kubectl label node demo-control-plane ingress-ready=true --overwrite
```

Wait for the controller pod to be running:

```sh
kubectl get pods -n ingress-nginx
```

Once the controller is running, you can proceed with applying your app, service, and ingress manifests.

---

## How the Flow Works

1. **Deploy blue version** and expose via Service and Ingress.
2. **Deploy green version** (new version) and expose via its own Service.
3. **Test green** (internally or by temporarily editing the Ingress to point to green).
4. **Switch Ingress** to route all traffic to green Service by editing `5-ingress.yaml` and re-applying.
5. **Optionally remove blue** after confirming green is healthy.

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
|  Test Green (optional)      |
+-----------------------------+
            |
            v
+-----------------------------+
|  Switch Ingress to Green?   |
+-----------------------------+
      |             |
     Yes           No
      |             |
+---------------------+   +---------------------+
| Service -> Green    |   | Keep Blue Live      |
+---------------------+   +---------------------+
      |
      v
+-----------------------------+
| Remove Blue (Optional)      |
+-----------------------------+
```

---

## CLI Tips
- **Check Ingress:**
  ```sh
  kubectl get ingress
  kubectl describe ingress myapp-ingress
  ```
- **Test access (from your machine):**
  ```sh
  curl -H "Host: myapp.local" http://<your-cluster-ip>/
  ```
  (You may need to add `myapp.local` to your `/etc/hosts` pointing to your cluster's ingress IP.)

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

## Test Ingress from Outside the Cluster (Local Machine)

If your Ingress controller is not exposed externally, you can use port-forwarding to access it from your local machine for testing:

### Step 1: Port-forward the Ingress controller service

In a separate terminal, run:

```sh
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
```

This will forward your local port 8080 to the Ingress controller's port 80 inside the cluster.

### Step 2: Test with curl

Now, you can run:

```sh
for i in `seq 1 1000`; do curl -H "Host: myapp.local" http://localhost:8080/; echo ""; sleep 1; done
```

- Replace `myapp.local` with the host defined in your Ingress resource.
- Make sure the port in the curl command matches the port you used in port-forwarding (8080 in this example).

---

## Test Ingress from Your Local Machine

Once the Ingress controller is running and your Ingress resource is applied, you can test access from your local machine with:

```sh
curl -H "Host: myapp.local" http://localhost:8080/
```

- Replace `myapp.local` with the host defined in your Ingress resource if different.

---

## Notes
- This approach is simple and does not require a service mesh.
- For production, consider automation or tools like Flagger for safer rollouts. 