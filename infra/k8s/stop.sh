#!/bin/bash
set -euo pipefail

echo "Deleting all deployments in default namespace..."
kubectl delete deployments --all -n default

echo "Deleting all services in default namespace..."
kubectl delete services --all -n default

echo "Deleting all pods in default namespace..."
kubectl delete pods --all -n default

echo "All resources stopped." 