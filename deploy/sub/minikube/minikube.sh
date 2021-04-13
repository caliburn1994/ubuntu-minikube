#!/usr/bin/env bash
set -e

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
CURRENT_DIR=$(dirname "$0")


# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_info "Running ${CURRENT_DIR}"
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

if ! groups | grep docker &>/dev/null; then
  echo_debug "Adding current user to docker group... "
  # add the current user to docker group
  getent group docker &>/dev/null || sudo groupadd docker
  sudo usermod -aG docker "${USER}"

  echo_info "For taking effect on usermod globally,It is necessary to reboot."
  echo_info 'Reboot now? (y/n)' && read -r x && [[ "$x" == "y" ]] && /sbin/reboot;
  exit
fi

# install kubectl
if ! type -p kubectl &>/dev/null; then
  echo_debug "Installing kubectl..."

  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  kubectl version --client

  # auto completion
  # shellcheck disable=SC1090
  source <(kubectl completion bash)
  echo "source <(kubectl completion bash)" >>~/.bashrc
fi

# install minikube
# https://minikube.sigs.k8s.io/docs/start/
if ! type -p minikube &>/dev/null; then
  echo_debug "Installing minikube..."

  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
  sudo dpkg -i minikube_latest_amd64.deb
  rm minikube_latest_amd64.deb

  # auto completion
  # shellcheck disable=SC1090
  source <(minikube completion bash)
  echo "source <(minikube completion bash)" >>~/.bashrc

  minikube start
  minikube addons enable ingress

  # run minikube when boot up
  SERVICE_NAME="minikube.service"
  tmpdir=$(mktemp -d)
  echo_debug "Installing minikube as service..."
  envsubst < "${CURRENT_DIR}/${SERVICE_NAME}" > "${tmpdir}/${SERVICE_NAME}"
  sudo cp "${tmpdir}/${SERVICE_NAME}" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable "${SERVICE_NAME}"
  sudo systemctl start "${SERVICE_NAME}"

  # run minikube dashboard when boot up
  SERVICE_NAME="minikube-dashboard.service"
  tmpdir=$(mktemp -d)
  echo_debug "Installing minikube dashboard as service..."
  envsubst < "${CURRENT_DIR}/${SERVICE_NAME}" > "${tmpdir}/${SERVICE_NAME}"
  sudo cp "${tmpdir}/${SERVICE_NAME}" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable "${SERVICE_NAME}"
  sudo systemctl start "${SERVICE_NAME}"

fi
