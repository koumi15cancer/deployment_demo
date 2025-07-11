# Kubernetes Setup: Istio & Flagger (for kind clusters)

This guide helps you quickly set up **Istio** and **Flagger** in your local kind (Kubernetes in Docker) cluster for progressive delivery demos.

---

## Prerequisites
- A running [kind](https://kind.sigs.k8s.io/) cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed and configured
- [Helm](https://helm.sh/) installed (see below)

---

## 0. Install Helm (if not already installed)

[Helm](https://helm.sh/) is a package manager for Kubernetes. You need it to install Flagger.

**On macOS (with Homebrew):**
```sh
brew install helm
```

**On Linux:**
```sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**On Windows (with Chocolatey):**
```sh
choco install kubernetes-helm
```

For other methods, see the [official Helm install guide](https://helm.sh/docs/intro/install/).

---

## 1. Install Istio (Service Mesh)

```sh
# Download Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH

# Install Istio (demo profile)
istioctl install --set profile=demo -y

# Enable automatic sidecar injection for the default namespace
kubectl label namespace default istio-injection=enabled
```

---

## 2. Install Flagger (with Helm)

```sh
helm repo add flagger https://flagger.app
helm repo update
helm upgrade -i flagger flagger/flagger \
  --namespace istio-system \
  --set meshProvider=istio \
  --set prometheus.install=true
```

---

## 3. (Optional) Install Flagger Loadtester

Flagger uses a loadtester pod for webhooks and analysis:

```sh
kubectl apply -k github.com/fluxcd/flagger//kustomize/tester
```

---

## 4. Verify Installation

- Check Istio pods:
  ```sh
  kubectl get pods -n istio-system
  ```
- Check Flagger pod:
  ```sh
  kubectl get pods -n istio-system | grep flagger
  ```
- Check Loadtester (optional):
  ```sh
  kubectl get pods -n istio-system | grep loadtester
  ```

---

## 5. Next Steps

- Deploy your demo manifests (see other folders in `examples/k8s/`).
- Watch Flagger logs:
  ```sh
  kubectl -n istio-system logs deployment/flagger -f
  ```

---

**For more details, see:**
- [Istio Docs](https://istio.io/latest/docs/setup/getting-started/)
- [Flagger Docs](https://docs.flagger.app/) 