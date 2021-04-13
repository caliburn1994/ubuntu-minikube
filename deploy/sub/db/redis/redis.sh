#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
CURRENT_DIR=$(dirname "$0")


# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_info "Running $(basename "$0")"




# install
K8S_SERVICE="redis-cluster"
if ! kubectl get service "${K8S_SERVICE}" &>/dev/null; then
  echo_debug "Installing Redis..."
  # https://github.com/bitnami/charts/tree/master/bitnami/redis-cluster
  helm install --timeout 600s redis-cluster bitnami/redis-cluster
fi









#NAME: myrelease
#LAST DEPLOYED: Fri Apr  9 18:31:01 2021
#NAMESPACE: default
#STATUS: deployed
#REVISION: 1
#TEST SUITE: None
#NOTES:
#** Please be patient while the chart is being deployed **
#
#
#To get your password run:
#    export REDIS_PASSWORD=$(kubectl get secret --namespace default myrelease-redis-cluster -o jsonpath="{.data.redis-password}" | base64 --decode)
#
#You have deployed a Redis(TM) Cluster accessible only from within you Kubernetes Cluster.INFO: The Job to create the cluster will be created.To connect to your Redis(TM) cluster:
#
#1. Run a Redis(TM) pod that you can use as a client:
#kubectl run --namespace default myrelease-redis-cluster-client --rm --tty -i --restart='Never' \
# --env REDIS_PASSWORD=$REDIS_PASSWORD \
#--image docker.io/bitnami/redis-cluster:6.0.10-debian-10-r5 -- bash
#
#2. Connect using the Redis(TM) CLI:
#
#redis-cli -c -h myrelease-redis-cluster -a $REDIS_PASSWORD
