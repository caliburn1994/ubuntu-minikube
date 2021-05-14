#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../../.. >/dev/null 2>&1 && pwd)"
# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

function download() {
    sudo mkdir -p "/etc/docker-compose/localstack"
    curl -L https://raw.githubusercontent.com/localstack/localstack/master/docker-compose.yml -o "/etc/docker-compose/localstack/docker-compose.yml"
    make_service "localstack.service"
}


echo_running
download