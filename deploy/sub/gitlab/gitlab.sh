#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
CURRENT_DIR=$(dirname "$0")
CONFIG_FILE_LOCATION="${CURRENT_DIR}/gitlab.yaml"
CONFIG_FILE_TEMPLATE_LOCATION="${CURRENT_DIR}/gitlab-template.yaml"

#  dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

bash "${PROJECT_ROOT_PATH}/deploy/sub/db/psql/psql.sh"
echo_info "Running ${CURRENT_DIR}/$(basename $0)"
# https://docs.gitlab.com/charts/development/minikube/
if ! kubectl get pods | grep gitlab &>/dev/null; then
  helm repo add gitlab https://charts.gitlab.io/
  helm repo update

  # ip could be:
  # - $(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
  # - $(minikube ip)
  ip="$(minikube ip)"
  export ip

  # install gitlab
  envsubst <"${CONFIG_FILE_TEMPLATE_LOCATION}" >"${CONFIG_FILE_LOCATION}"
  helm upgrade --install gitlab gitlab/gitlab \
    --timeout 600s \
    -f "$CONFIG_FILE_LOCATION"
  rm CONFIG_FILE_LOCATION

  cat <<EOF >"${PROJECT_ROOT_PATH}/out/gitlab/open-gitlab.sh"
#!/usr/bin/env bash
user=root
password=$(
    kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode
    echo
  )
url-inner=https://gitlab.${ip}.nip.io"
url-server=http://192.168.0.180:9000
EOF

  # gitlab service
  SERVICE_NAME="minikube-gitlab.service"
  tmpdir=$(mktemp -d)
  echo_debug "forward redis fo gitlab as a service..."
  envsubst < "${CURRENT_DIR}/${SERVICE_NAME}" > "${tmpdir}/${SERVICE_NAME}"
  sudo cp "${tmpdir}/${SERVICE_NAME}" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable "${SERVICE_NAME}"
  sudo systemctl start "${SERVICE_NAME}"


  # gitlab-redis service
  SERVICE_NAME="minikube-gitlab-redis.service"
  tmpdir=$(mktemp -d)
  echo_debug "forward redis fo gitlab as a service..."
  envsubst < "${CURRENT_DIR}/${SERVICE_NAME}" > "${tmpdir}/${SERVICE_NAME}"
  sudo cp "${tmpdir}/${SERVICE_NAME}" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable "${SERVICE_NAME}"
  sudo systemctl start "${SERVICE_NAME}"

  redis_password=$(kubectl get secrets --namespace default gitlab-redis-secret -o jsonpath="{.data.secret}" | base64 --decode)
  cat <<EOF >"${PROJECT_ROOT_PATH}/out/gitlab/gitlab-redis.properties"
# window tool: https://github.com/qishibo/AnotherRedisDesktopManager
# by command:
#   redis-cli -c -h 127.0.0.1 -a ${redis_password}
password=${redis_password}
port=6379
EOF

fi




# check gitlab if normal
rsl=$(kubectl get ingress -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')
if [ $? -ne 0 ] && [ ! "$rsl" ]; then
  echo_warn "❌ Do you enable the minikube plugin ingress? like this"
  echo_warn "minikube addons enable ingress"
fi
