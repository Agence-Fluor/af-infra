#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/settings.sh

echo ======================================================
echo "Deleting kube distro ${CLUSTER_ENGINE}..."
$SCRIPT_DIR/kube-distros/${CLUSTER_ENGINE}/kube-uninstall.sh
echo "Kube deleted."
echo ======================================================