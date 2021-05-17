#!/usr/bin/env bash
set -e

SCRIPT_MODULE=deploy
PROJECT_ROOT_PATH="$(pwd | awk -F "/${SCRIPT_MODULE}" '{print $1}')" && source "${PROJECT_ROOT_PATH}/deploy/common.sh"

# https://docs.docker.com/engine/install/ubuntu/
function install_docker() {
  type -p docker &>/dev/null && return 0

  echo_debug "Installing docker..."
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

  # tcp
  #  sudo vim /lib/systemd/system/docker.service
  sudo systemctl daemon-reload
  sudo systemctl restart docker.service
  sudo mkdir -p /etc/systemd/system/docker.service.d # https://docs.docker.com/config/daemon/systemd/

  # test
  sudo docker run hello-world
}

# https://docs.docker.com/compose/install/
function install_docker_compose() {
  type -p docker-compose &>/dev/null && return 0

  echo_debug "Installing docker..."
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.1/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose
}

# add the current user to docker group
function add_user2group() {
  groups | grep docker &>/dev/null && return 0

  echo_debug "Adding current user to docker group... "
  getent group docker &>/dev/null || sudo groupadd docker
  sudo usermod -aG docker "${USER}"
  echo_info "For taking effect on usermod globally,It is necessary to reboot."
  echo_info 'Reboot now? (y/n)' && read -r x && [[ "$x" == "y" ]] && /sbin/reboot
  exit
}

# main
echo_running
install_docker
install_docker_compose
add_user2group