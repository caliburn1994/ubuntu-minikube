#!/usr/bin/env bash

SCRIPT_MODULE=deploy
PROJECT_ROOT_PATH="$(echo "${BASH_SOURCE[0]}" | awk -F "/${SCRIPT_MODULE}" '{print $1}')" && source "${PROJECT_ROOT_PATH}/deploy/common.sh"

function download() {
  dc_file="/etc/docker-compose/localstack/docker-compose.yml"
  ls ${dc_file} >>/dev/null 2>&1 && return 0

  sudo mkdir -p "/etc/docker-compose/localstack"
  curl -L https://raw.githubusercontent.com/localstack/localstack/master/docker-compose.yml -o "{dc_file}"
  make_service "localstack.service"
}

function output_config() {
  file="${PROJECT_ROOT_PATH}/out/localstack/expose_ip.txt"
  if [ ! -s $file ]; then
    echo "http://$(sudo minikube ip):4566" >"$file"
  fi
}

function heath_check() {
  url=$(cat "${PROJECT_ROOT_PATH}/out/localstack/expose_ip.txt")
  rsl=$(curl -s "$url") # -s silent

  [[ ${rsl} != '{"status": "running"}' ]] && echo_warn "Localstack was broken"
}

echo_running
download
output_config
heath_check
