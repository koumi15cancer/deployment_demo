#!/bin/bash
set -euo pipefail

echo "Running from: $(pwd)"
echo "Template dir: $(dirname "$0")/template"
echo "Env file: $(dirname "$0")/env/prod_values.yaml"
echo "Files in template dir:"
ls -l "$(dirname "$0")/template"

# Directory paths
TEMPLATE_DIR="$(dirname "$0")/template"
ENV_FILE="$(dirname "$0")/env/prod_values.yaml"
RENDER_DIR="/tmp/k8s-rendered-$(date +%s)"

mkdir -p "$RENDER_DIR"

# Render all templates
for tmpl in "$TEMPLATE_DIR"/*.yaml; do
  [ -e "$tmpl" ] || continue
  out="$RENDER_DIR/$(basename "$tmpl")"
  ktmpl "$tmpl" -f "$ENV_FILE" > "$out"
  echo "Rendered $tmpl -> $out"
done

echo "Applying manifests to the current Kubernetes context..."
for manifest in "$RENDER_DIR"/*.yaml; do
  kubectl apply -f "$manifest"
done

echo "Deployment complete. Resources:"
kubectl get deployments
kubectl get services 