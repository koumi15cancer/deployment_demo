#!/bin/bash

# Namespaces to skip
SKIP_NAMESPACES=("kube-system" "kube-public" "kube-node-lease" "default")

# Function to check if a namespace should be skipped
should_skip() {
  local ns="$1"
  for skip in "${SKIP_NAMESPACES[@]}"; do
    if [[ "$ns" == "$skip" ]]; then
      return 0
    fi
  done
  return 1
}

# Clean up all resources in the default namespace
kubectl delete all --all -n default
kubectl delete configmap --all -n default
kubectl delete secret --all -n default
kubectl delete pvc --all -n default
kubectl delete ingress --all -n default
kubectl delete service --all -n default --ignore-not-found

echo "Cleaned up all resources in the default namespace."

# Get all namespaces except system ones
for ns in $(kubectl get ns --no-headers -o custom-columns=":metadata.name"); do
  if should_skip "$ns"; then
    echo "Skipping namespace: $ns"
    continue
  fi
  echo "Cleaning namespace: $ns"
  kubectl delete all --all -n "$ns"
  kubectl delete configmap --all -n "$ns"
  kubectl delete secret --all -n "$ns"
  kubectl delete pvc --all -n "$ns"
  kubectl delete ingress --all -n "$ns"
  kubectl delete service --all -n "$ns" --ignore-not-found
  echo "Cleaned up all resources in namespace: $ns"
done

echo "All user-created namespaces have been cleaned up." 