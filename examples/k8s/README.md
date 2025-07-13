# Kubernetes Sample Runner

## 1. Install Kind (Kubernetes IN Docker)

Kind lets you run Kubernetes clusters locally using Docker.  
Follow the instructions for your OS:

### macOS
```sh
brew install kind
```

### Windows (with Chocolatey)
```sh
choco install kind
```

### Linux
```sh
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

---

## 2. Create a Local Cluster for This Demo

```sh
kind create cluster --name demo-cluster
```

> **Tip:** Delete the cluster with:
> ```sh
> kind delete cluster --name demo-cluster
> ```

---

## 3. Check if Your Local Cluster is Running (Dry Run)

Run this command to verify your cluster is up and accessible:
```sh
kubectl cluster-info --context kind-demo-cluster
```
If you see cluster and Kubernetes master URLs, your cluster is running locally.

---

## 4. Quick Start

1. **Clean and Run a Sample**

   To clean all namespaces and apply a sample scenario (e.g., `1-rolling-updates`):

   ```sh
   make run-sample 1
   ```
   Replace `1` with the desired sample index (e.g., `2` for `2-recreate`, `3` for `3-blue-green`, etc.).

2. **View Curl Test Logs**

   After running a sample, you can watch the logs from the automated curl deployment:

   ```sh
   make show-curl-logs
   ```

---

## How It Works
- Each `make run-sample <index>` command:
  1. Cleans up all resources in all namespaces (except system namespaces).
  2. Applies all manifests in the `<index>-*` sample folder.
  3. Deploys a curl pod that continuously tests the sample service and outputs results to the logs.

## Requirements
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [make](https://www.gnu.org/software/make/)
- [kind](https://kind.sigs.k8s.io/)

---

## References
- [Kind Official Documentation](https://kind.sigs.k8s.io/)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [GNU Make](https://www.gnu.org/software/make/)

---

Enjoy fast, repeatable Kubernetes scenario testing! 