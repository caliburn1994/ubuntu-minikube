#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../../.. >/dev/null 2>&1 && pwd)"
POSTGRES_K8S_BASENAME="psql-cluster" && export POSTGRES_K8S_BASENAME
POSTGRES_K8S_SERVICE="${POSTGRES_K8S_BASENAME}-postgresql" && export POSTGRES_K8S_SERVICE
# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_running
# install
if ! kubectl get service "${POSTGRES_K8S_SERVICE}" &>/dev/null; then
  echo_debug "Installing PostgreSQL..."
  echo_debug "If helm version<3.1, use => helm install ${POSTGRES_K8S_BASENAME} bitnami/postgresql --version 10.2.2"
  echo_debug "If helm version>3.1, use => helm install ${POSTGRES_K8S_BASENAME} bitnami/postgresql"
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm install ${POSTGRES_K8S_BASENAME} bitnami/postgresql --version 10.2.2

  make_service "minikube-psql.service"
fi

# output result
POSTGRES_PASSWORD="$(kubectl get secret --namespace default ${POSTGRES_K8S_SERVICE} -o jsonpath="{.data.postgresql-password}" | base64 --decode)"

if ! kubectl get service "${POSTGRES_K8S_SERVICE}" &>/dev/null; then
  # command tools
  sudo apt-get install -y postgresql-client-common
  sudo apt-get install -y postgresql-client

  echo_info "For creating a new custom database,you should input this password: ${POSTGRES_PASSWORD}"
  # create new database
  createdb -h localhost -p 5432 -U postgres testdb
fi

# config
cat <<EOF >"${PROJECT_ROOT_PATH}/out/db/psql.properties"
# custom
url=jdbc:postgresql://localhost:5432/testdb
# for gitlab
url=jdbc:postgresql://localhost:5432/postgres
username=postgres
password=${POSTGRES_PASSWORD}
EOF