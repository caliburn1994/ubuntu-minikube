#!/usr/bin/env bash

SCRIPT_MODULE=deploy
PROJECT_ROOT_PATH="$(echo "${BASH_SOURCE[0]}" | awk -F "/${SCRIPT_MODULE}" '{print $1}')" && source "${PROJECT_ROOT_PATH}/deploy/common.sh"

# constant
POSTGRES_K8S_BASENAME="psql-cluster" && export POSTGRES_K8S_BASENAME
POSTGRES_K8S_SERVICE="${POSTGRES_K8S_BASENAME}-postgresql" && export POSTGRES_K8S_SERVICE

# install
function install_psql() {
  if sudo kubectl get service "${POSTGRES_K8S_SERVICE}" &>/dev/null; then return 0; fi

  echo_debug "Installing PostgreSQL..."
  echo_debug "If helm version<3.1, use => helm install ${POSTGRES_K8S_BASENAME} bitnami/postgresql --version 10.2.2"
  echo_debug "If helm version>3.1, use => helm install ${POSTGRES_K8S_BASENAME} bitnami/postgresql"
  sudo helm repo add bitnami https://charts.bitnami.com/bitnami
  sudo helm install ${POSTGRES_K8S_BASENAME} bitnami/postgresql --version 10.2.2 -f "${CURRENT_DIR}/value.yaml"

  make_service "minikube-psql.service"
}

POSTGRES_PASSWORD="$(sudo kubectl get secret --namespace default ${POSTGRES_K8S_SERVICE} -o jsonpath="{.data.postgresql-password}" | base64 --decode)"
function create_db() {
  if type -p createdb &>/dev/null; then return 0; fi
  sudo apt-get install -y postgresql-client-common postgresql-client
  export "PGPASSWORD=${POSTGRES_PASSWORD}"
  createdb -h localhost -p 5432 -U postgres testdb
}

echo_running "${BASH_SOURCE[0]}"
install_psql
create_db

# output config
cat <<EOF >"${PROJECT_ROOT_PATH}/out/db/psql.properties"
url=jdbc:postgresql://localhost:5432/postgres
username=postgres
password=${POSTGRES_PASSWORD}
EOF
cat <<EOF >"${PROJECT_ROOT_PATH}/out/db/psql-2.properties"
url=jdbc:postgresql://localhost:5432/testdb
username=postgres
password=${POSTGRES_PASSWORD}
EOF
