#!/bin/bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "[INFO] Worker bootstrap started"

if [ -f /etc/kubernetes/kubelet.conf ]; then
  echo "[INFO] Worker already joined"
  exit 0
fi

bash /tmp/kubeadm_join.sh

echo "[SUCCESS] Worker joined"
