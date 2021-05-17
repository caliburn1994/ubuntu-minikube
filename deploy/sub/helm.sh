#!/usr/bin/env bash

SCRIPT_MODULE=deploy
PROJECT_ROOT_PATH="$( echo "${BASH_SOURCE[0]}"  | awk -F "/${SCRIPT_MODULE}" '{print $1}')" && source "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_running
# https://helm.sh/zh/
if ! type -p helm &>/dev/null; then
  sudo snap install helm --classic
  # shellcheck disable=SC1090
  source <(helm completion bash)
  echo "source <(helm completion bash)" >>~/.bashrc
fi
