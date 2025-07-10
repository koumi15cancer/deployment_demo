# Rolling Updates Example

This folder demonstrates a basic Kubernetes rolling update deployment.

## How to Apply

> **Copy the following commands:**

```sh {copy}
kubectl apply -f 1-deployment.yaml
kubectl apply -f 3-service.yaml
```

You can copy and paste the above commands into your terminal to deploy the resources.

---

- `1-deployment.yaml`: Defines the rolling update deployment for the application.
- `3-service.yaml`: Exposes the deployment as a Kubernetes service.

---

## Test Network Connectivity with Curl Pod

You can launch a temporary pod with curl to test network connectivity inside your cluster:

```sh {copy}
kubectl run curl --image=alpine/curl:8.2.1 -n kube-system -i --tty --rm -- sh
```

This command starts a pod in the `kube-system` namespace using the `alpine/curl` image, giving you an interactive shell with curl available. The pod is removed after you exit the shell.

---

## Repeatedly Call the /hello Endpoint

To continuously send requests to the `/hello` endpoint of your service (useful for testing rolling updates and observing pod behavior), run the following command inside the curl pod shell:

```sh {copy}
for i in `seq 1 1000`; do curl myapp.default:8181/hello; echo ""; sleep 1; done
```

This loop will send a request to `myapp.default:8181/hello` every second, 1000 times, printing the response each time. This is helpful for monitoring how your service responds during updates or changes. 