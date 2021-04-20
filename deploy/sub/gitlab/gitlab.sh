#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
#  dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_running
# https://docs.gitlab.com/charts/development/minikube/
if ! kubectl get pods | grep gitlab &>/dev/null; then
  helm repo add gitlab https://charts.gitlab.io/
  helm repo update

  # ip could be:
  # - $(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
  # - $(minikube ip)
  #
  # install gitlab
  ip="$(minikube ip)" && export ip
  tmpdir=$(mktemp -d)
  envsubst <"${CURRENT_DIR}/gitlab.yaml" >"${tmpdir}/gitlab.yaml"
  helm upgrade --install gitlab gitlab/gitlab \
    --timeout 600s \
    -f "${tmpdir}/gitlab.yaml"

  # service
  make_service "minikube-gitlab.service"
  make_service "minikube-gitlab-redis.service"
fi

# config
redis_password=$(kubectl get secrets --namespace default gitlab-redis-secret -o jsonpath="{.data.secret}" | base64 --decode)
cat <<EOF >"${PROJECT_ROOT_PATH}/out/gitlab/gitlab-redis.properties"
# window tool: https://github.com/qishibo/AnotherRedisDesktopManager
# by command:
#   redis-cli -c -h 127.0.0.1 -a ${redis_password}
password=${redis_password}
port=6379
EOF

cat <<EOF >"${PROJECT_ROOT_PATH}/out/gitlab/gitlab.properties"
#!/usr/bin/env bash
user=root
password=$(
    kubectl get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode
    echo
  )
url-inner=https://gitlab.${ip}.nip.io"
EOF


# check gitlab if normal
if ! minikube addons list | grep  ingress | grep -v dns | grep enabled &>/dev/null; then
  echo_warn "❌ Do you enable the minikube plugin ingress? like this"
  echo_warn "minikube addons enable ingress"
fi