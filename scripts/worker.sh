#!/bin/bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

if [[ -z "${MASTER_IP:-}" ]]; then
  echo "[ERROR] MASTER_IP is not set"
  exit 1
fi

echo "[INFO] Worker bootstrap started"

if [ -f /etc/kubernetes/kubelet.conf ]; then
  echo "[INFO] Worker already joined"
  exit 0
fi

JOIN_CMD=$(ssh -o BatchMode=yes \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  kubeadmin@$MASTER_IP \
  'sudo cat /tmp/kubeadm_join.sh')

sudo $JOIN_CMD

echo "[SUCCESS] Worker joined"
