#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. >/dev/null 2>&1 && pwd)"
CURRENT_DIR=$(dirname "$0")

# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_info "Running ${CURRENT_DIR}"
# https://helm.sh/zh/
if ! type -p helm &>/dev/null; then
  sudo snap install helm --classic
  # shellcheck disable=SC1090
  source <(helm completion bash)
  echo "source <(helm completion bash)" >>~/.bashrc
fi
