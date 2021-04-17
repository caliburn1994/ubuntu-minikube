#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
CURRENT_DIR=$(dirname "$0")

# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_info "Running ${CURRENT_DIR}/$(basename $0)"

if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa
fi

if ! kubectl get service my-sshd &>/dev/null; then
  echo "pubkey: $(cat ~/.ssh/id_rsa.pub)" | tee "${CURRENT_DIR}/values.yaml" >/dev/null
  helm install my-sshd -f "${CURRENT_DIR}/values.yaml" "${CURRENT_DIR}/sshd"
fi
# kubectl port-forward --namespace default svc/my-sshd 2222:22 --address 0.0.0.0

