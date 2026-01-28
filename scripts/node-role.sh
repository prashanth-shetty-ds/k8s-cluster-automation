#!/bin/bash

HOSTNAME=$(hostname)

if [[ "$HOSTNAME" == "master-0" ]]; then
  echo "MASTER"
elif [[ "$HOSTNAME" == worker-* ]]; then
  echo "WORKER"
else
  echo "UNKNOWN"
fi
