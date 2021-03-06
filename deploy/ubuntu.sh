#!/usr/bin/env bash
# ubuntu 20
set -e
SCRIPT_MODULE=deploy
PROJECT_ROOT_PATH="$( echo "${BASH_SOURCE[0]}"  | awk -F "/${SCRIPT_MODULE}" '{print $1}')" && source "${PROJECT_ROOT_PATH}/deploy/common.sh"

# variables
CURRENT_DIR=$(dirname "$0")


echo_info "Running ${CURRENT_DIR}/$(basename $0)"
function install_desktop_apps() {
  # for logitech keyboard and mouse
  sudo apt-get install -y solaar
  # pinyin,screenshot
  sudo apt-get install -y ibus-sunpinyin flameshot
  ibus restart
  # office
  sudo snap install notepad-plus-plus # notepad++

  # typora
  # https://support.typora.io/Typora-on-Linux/
  if ! type -p typora &>/dev/null; then
    wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
    sudo add-apt-repository 'deb https://typora.io/linux ./'
    sudo apt-get update
    sudo apt-get install typora
  fi

  # chrome
  if ! type -p google-chrome &>/dev/null; then
      wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo apt install ./google-chrome-stable_current_amd64.deb && rm ./google-chrome-stable_current_amd64.deb
  fi
}


function install_tools() {
  # system
  sudo apt-get install -y openssh-server git make curl vim net-tools jq conntrack build-essential procps file
  # Homebrew
  git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
  mkdir ~/.linuxbrew/bin
  ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
  eval $(~/.linuxbrew/bin/brew shellenv)
  echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bashrc

  # development tools
  sudo apt-get install -y npm
  bash "${PROJECT_ROOT_PATH}/deploy/sub/java.sh"

  # local cloud
  bash "${PROJECT_ROOT_PATH}/deploy/sub/helm.sh"
  bash "${PROJECT_ROOT_PATH}/deploy/sub/docker.sh"
  bash "${PROJECT_ROOT_PATH}/deploy/sub/minikube/minikube.sh"
  # database in cloud
  sudo apt-get install -y redis-tools
  bash "${PROJECT_ROOT_PATH}/deploy/sub/db/psql/psql.sh"

  # application in cloud
  bash "${PROJECT_ROOT_PATH}/deploy/sub/gitlab/gitlab.sh"

  # local aws
  bash "${PROJECT_ROOT_PATH}/deploy/sub/localstack/docker-compose/docker-compose.sh"
  bash "${PROJECT_ROOT_PATH}/deploy/sub/localstack/aws-cli.sh"
  bash "${PROJECT_ROOT_PATH}/deploy/sub/localstack/terraform.sh"
}

install_desktop_apps
install_tools
