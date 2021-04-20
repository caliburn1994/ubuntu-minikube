#!/usr/bin/env bash

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


function make_service() {
  service_name=${1}

  echo_debug "Making service ${service_name}"
  tmpdir=$(mktemp -d)
  envsubst < "${CURRENT_DIR}/${service_name}" > "${tmpdir}/${service_name}"
  sudo cp "${tmpdir}/${service_name}" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable "${service_name}"
  sudo systemctl start "${service_name}"
}
