#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_running
# install https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/install-cliv2-linux.html
if ! type -p aws &>/dev/null; then

  gpg --import aswcliv2-public-key # import public key

  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig" -o "awscliv2.sig"

  if gpg --verify awscliv2.sig awscliv2.zip ; then # if sign is verified， install
    unzip awscliv2.zip
    sudo ./aws/install
  fi
  rm -rf ./aws/install awscliv2.zip awscliv2.sig

fi
