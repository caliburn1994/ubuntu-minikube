#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
CURRENT_DIR=$(dirname "$0")
CONFIG_FILE_LOCATION="${CURRENT_DIR}/gitlab.yaml"
CONFIG_FILE_TEMPLATE_LOCATION="${CURRENT_DIR}/gitlab-template.yaml"

#  dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

bash "${PROJECT_ROOT_PATH}/deploy/sub/db/psql/psql.sh"
echo_info "Running ${CURRENT_DIR}"
# https://docs.gitlab.com/charts/development/minikube/
if ! kubectl get pods | grep gitlab &>/dev/null; then
  helm repo add gitlab https://charts.gitlab.io/
  helm repo update

  # ip could be:
  # - $(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
  # - $(minikube ip)
  ip="$(minikube ip)"
  export ip

  envsubst <"${CONFIG_FILE_TEMPLATE_LOCATION}" >"${CONFIG_FILE_LOCATION}"
  helm upgrade --install gitlab gitlab/gitlab \
    --timeout 600s \
    -f "$CONFIG_FILE_LOCATION"
  rm CONFIG_FILE_LOCATION

  cat <<EOF >"${PROJECT_ROOT_PATH}/config/bin/open-gitlab.sh"
#!/usr/bin/env bash
echo "user: root"
echo password: $(
    kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode
    echo
  )
xdg-open https://gitlab.${ip}.nip.io
EOF
fi

# check gitlab if normal
rsl=$(kubectl get ingress -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')
if [ $? -ne 0 ] && [ ! "$rsl" ]; then
  echo_warn "❌ Do you enable the minikube plugin ingress? like this"
  echo_warn "minikube addons enable ingress"
fi
