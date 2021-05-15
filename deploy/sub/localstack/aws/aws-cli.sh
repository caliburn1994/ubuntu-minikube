#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../../.. >/dev/null 2>&1 && pwd)"
# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

# https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/install-cliv2-linux.html
function install() {
  type -p aws &>/dev/null && return 0

  echo_debug "Installing aws-cli..."
  gpg --import aswcliv2-public-key # import public key
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig" -o "awscliv2.sig"
  if gpg --verify awscliv2.sig awscliv2.zip; then # if sign is verified， install
    unzip awscliv2.zip
    sudo ./aws/install
  fi
  rm -rf ./aws/install awscliv2.zip awscliv2.sig

  # sam
  brew tap aws/tap
  brew install aws-sam-cli
  sam --version &>/dev/null || echo_warn "failed to install sam "

  # auto-completion
  # shellcheck disable=SC2016
  echo 'export PATH=/usr/local/bin:$PATH' | tee -a ~/.bashrc
  export PATH=/usr/local/bin:$PATH
  echo 'complete -C '/usr/local/bin/aws_completer' aws' | tee -a ~/.bashrc
}

function config_profile() {
  aws configure list &>/dev/null && return 0

  ls ~/.aws/ &>/dev/null || cp -r "${CURRENT_DIR}/.aws" "$HOME"
  echo "export AWS_PROFILE=localstack" | tee -a ~/.bashrc
}

# main
echo_running
install
config_profile
