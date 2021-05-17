#!/usr/bin/env bash

SCRIPT_MODULE=deploy
PROJECT_ROOT_PATH="$( echo "${BASH_SOURCE[0]}"  | awk -F "/${SCRIPT_MODULE}" '{print $1}')" && source "${PROJECT_ROOT_PATH}/deploy/common.sh"
source_root "deploy/sub/db/psql/psql.sh"

# variables
ip="$(sudo minikube ip)" && export ip

# https://docs.gitlab.com/charts/development/minikube/
function install_gitlab() {
  if sudo kubectl get pods | grep gitlab &>/dev/null; then return 0; fi

  sudo helm repo add gitlab https://charts.gitlab.io/
  sudo helm repo update

  local tmp_dir
  tmp_dir=$(mktemp -d)
  envsubst <"${CURRENT_DIR}/gitlab.yaml" >"${tmp_dir}/gitlab.yaml"
  sudo helm upgrade --install gitlab gitlab/gitlab \
    --timeout 600s \
    -f "${tmp_dir}/gitlab.yaml"
}

function check_minikube() {
  if sudo minikube addons list | grep ingress | grep -v dns | grep -q enabled; then return 0; fi

  echo_warn "❌ Do you enable the minikube plugin ingress? like this"
  echo_warn "minikube addons enable ingress"
}



echo_running
install_gitlab
make_service "minikube-gitlab-redis.service"
check_minikube

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
