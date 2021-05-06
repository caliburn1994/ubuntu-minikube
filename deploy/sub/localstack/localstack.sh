#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_running
# install
if ! sudo kubectl get service localstack &>/dev/null; then
  sudo helm repo add localstack-repo http://helm.localstack.cloud
  sudo helm upgrade --install localstack localstack-repo/localstack
fi

NODE_PORT=$(sudo kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services localstack)
NODE_IP=$(sudo kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
URL=http://$NODE_IP:$NODE_PORT
cat <<EOF >"${PROJECT_ROOT_PATH}/out/localstack.html"
<meta http-equiv="refresh" content="0; url=${URL}" />
EOF