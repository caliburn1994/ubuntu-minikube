#!/usr/bin/env bash
set -e

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. >/dev/null 2>&1 && pwd)"
# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"


echo_running
# install docker
if ! type -p docker &>/dev/null; then
  echo_debug "Installing docker..."

  # https://docs.docker.com/engine/install/ubuntu/
  sudo apt-get update
  sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo apt-key fingerprint 0EBFCD88

  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

  # test
  sudo docker run hello-world
fi

# assign user right
if ! groups | grep docker &>/dev/null; then
  echo_debug "Adding current user to docker group... "
  # add the current user to docker group
  getent group docker &>/dev/null || sudo groupadd docker
  sudo usermod -aG docker "${USER}"

  echo_info "For taking effect on usermod globally,It is necessary to reboot."
  echo_info 'Reboot now? (y/n)' && read -r x && [[ "$x" == "y" ]] && /sbin/reboot;
  exit
fi