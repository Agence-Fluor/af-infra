#!/usr/bin/env bash
set -e

echo "==> Uninstalling K3s..."
if [ -x /usr/local/bin/k3s-uninstall.sh ]; then
    sudo /usr/local/bin/k3s-uninstall.sh
fi

echo "==> Removing kubeconfig..."
rm -rf $HOME/.kube
unset KUBECONFIG

echo "==> Re-enabling IPv6..."
sudo rm -f /etc/sysctl.d/99-disable-ipv6.conf
sudo sysctl --system

echo "==> Cleanup complete!"
