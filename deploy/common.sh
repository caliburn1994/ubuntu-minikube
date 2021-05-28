#!/usr/bin/env bash

CURRENT_DIR=$(dirname "$0")

# color and echo
red=$(tput setaf 1)
green=$(tput setaf 2)
pink=$(tput setaf 13)
reset=$(tput sgr0)

function echo_warn() {
  LOG_PROMPT="[$(basename "${BASH_SOURCE[1]}")][${FUNCNAME[1]}]L${BASH_LINENO[0]}"
  echo "${LOG_PROMPT} ${red}${1}${reset}"
}

function echo_info() {
  LOG_PROMPT="[$(basename "${BASH_SOURCE[1]}")][${FUNCNAME[1]}]L${BASH_LINENO[0]}"
  echo "${LOG_PROMPT} ${green}${1}${reset}"
}

function echo_debug() {
  LOG_PROMPT="[$(basename "${BASH_SOURCE[1]}")][${FUNCNAME[1]}]L${BASH_LINENO[0]}"
  echo "${LOG_PROMPT} ${pink}${1}${reset}"
}

# message
function echo_running() {
  local base_name=${1-$0}
  base_name=$(basename "$base_name")
  echo_info "Running ${CURRENT_DIR}/${base_name}"
}

# para1 = service name
# para2 = is redeploy (default false)
function make_service() {
  local service_name=${1}
  local is_redeploy && is_redeploy=${2:-false}
  if systemctl --all --type service | grep -q "${service_name}" && ! ${is_redeploy}; then return 0; fi

  echo_debug "Making service ${service_name}"
  local tmp_dir
  tmp_dir=$(mktemp -d)
  envsubst <"${CURRENT_DIR}/${service_name}" >"${tmp_dir}/${service_name}"
  sudo cp "${tmp_dir}/${service_name}" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable "${service_name}"
  sudo systemctl start "${service_name}"
}

# dependencies
source_root() {
  local file="$PROJECT_ROOT_PATH/$1"
  if ! [[ $PROJECT_ROOT_PATH && -f "$file" ]]; then
    echo_warn "$file doesn't exist."
    exit 1
  fi

  echo_debug "import $file"
  # shellcheck disable=SC1090
  source "$file"
}
