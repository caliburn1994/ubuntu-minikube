#!/usr/bin/env bash

# color and echo
red=$(tput setaf 1)
green=$(tput setaf 2)
pink=$(tput setaf 13)
reset=$(tput sgr0)

function echo_warn() {
  echo "${red}${1}${reset}"
}

function echo_info() {
  echo "${green}${1}${reset}"
}

function echo_debug() {
  echo "${pink}${1}${reset}"
}

CURRENT_DIR=$(dirname "$0")
function echo_running() {
    echo_info "Running ${CURRENT_DIR}/$(basename $0)"
}

function make_service() {
  service_name=${1}

  echo_debug "Making service ${service_name}"
  tmp_dir=$(mktemp -d)
  envsubst < "${CURRENT_DIR}/${service_name}" > "${tmp_dir}/${service_name}"
  sudo cp "${tmp_dir}/${service_name}" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable "${service_name}"
  sudo systemctl start "${service_name}"
}
