#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
#  dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

# variables
. "${PROJECT_ROOT_PATH}/deploy/sub/db/psql/psql.sh"
ip="$(sudo minikube ip)" && export ip

echo_running
# install gitlab
# https://docs.gitlab.com/charts/development/minikube/
if ! sudo kubectl get pods | grep gitlab &>/dev/null; then
  sudo helm repo add gitlab https://charts.gitlab.io/ ; sudo helm repo update

  tmp_dir=$(mktemp -d)
  envsubst <"${CURRENT_DIR}/gitlab.yaml" >"${tmp_dir}/gitlab.yaml"
  sudo helm upgrade --install gitlab gitlab/gitlab \
    --timeout 600s \
    -f "${tmp_dir}/gitlab.yaml"

  # service
#  make_service "minikube-gitlab.service"
#  make_service "minikube-gitlab-redis.service"
fi

# out config
redis_password=$(sudo kubectl get secrets --namespace default gitlab-redis-secret -o jsonpath="{.data.secret}" | base64 --decode)
cat <<EOF >"${PROJECT_ROOT_PATH}/out/gitlab/gitlab-redis.properties"
# window tool: https://github.com/qishibo/AnotherRedisDesktopManager
# by command:
#   redis-cli -c -h 127.0.0.1 -a ${redis_password}
password=${redis_password}
port=6379
EOF
cat <<EOF >"${PROJECT_ROOT_PATH}/out/gitlab/gitlab.properties"
user=root
password=$(
    sudo kubectl get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode
    echo
  )
url-inner=https://gitlab.${ip}.nip.io
EOF


# check
if ! sudo minikube addons list | grep  ingress | grep -v dns | grep enabled; then
  echo_warn "❌ Do you enable the minikube plugin ingress? like this"
  echo_warn "minikube addons enable ingress"
fi