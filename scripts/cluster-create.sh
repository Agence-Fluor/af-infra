#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/settings.sh

echo ======================================================
echo "Installing cluster ${CLUSTER_NAME}..."
$SCRIPT_DIR/kube-distros/${CLUSTER_ENGINE}/cluster-create.sh
echo "Cluster created."
echo "Waiting for cluster to be ready..."
until kubectl get nodes >/dev/null 2>&1; do
    sleep 2
done
echo "Cluster is ready."
echo ======================================================

#==========================================
# SETUP NGINX INGRESS CONTROLLER
# =========================================

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --version 4.10.1 \
  --set controller.allowSnippetAnnotations=true
  

#==========================================
# SETUP CERT-MANAGER
# =========================================

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.15.0 \
  --set crds.enabled=true