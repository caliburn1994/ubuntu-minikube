#!/usr/bin/env bash
set -e

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_running
# install kubectl
if ! type -p kubectl &>/dev/null; then
  echo_debug "Installing kubectl..."

  curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  kubectl version --client

  # auto completion
  # shellcheck disable=SC1090
  source <(kubectl completion bash)
  echo "source <(kubectl completion bash)" >>~/.bashrc
fi


if [ "$(nproc --all)" -lt "2" ]; then
  echo_warn "CPU should be more than 1"
  exit
fi

# install minikube
# https://minikube.sigs.k8s.io/docs/start/
if ! type -p minikube &>/dev/null; then
  echo_debug "Installing minikube..."

  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb && sudo dpkg -i minikube_latest_amd64.deb && rm minikube_latest_amd64.deb

  # check selinux
  sudo apt-get install -y selinux-utils ethtool socat
  if [ "$(getenforce)" == "enforcing" ];then echo_warn "selinux should be permissive or disabled"; fi
  # check crictl
  VERSION="v1.21.0"
  if ! type -p type crictl &>/dev/null; then
      wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz && sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin && rm -f crictl-$VERSION-linux-amd64.tar.gz
  fi

  sudo systemctl enable kubelet.service
  swapoff -a # todo

  # auto completion
  # shellcheck disable=SC1090
  source <(minikube completion bash)
  echo "source <(minikube completion bash)" >>~/.bashrc

  # sudo sysctl fs.protected_regular=0
  sudo minikube start --vm-driver=none
#  sudo mv /root/.kube /root/.minikube $HOME
#  sudo chown -R $USER $HOME/.kube $HOME/.minikube
#  sudo chgrp -R $USER $HOME/.minikube $HOME/.kube
#  sudo chgrp -R $USER
#  minikube delete

  # run minikube when boot up
  # make_service "minikube.service" todo doesn't work

  # run minikube dashboard when boot up
  make_service "minikube-dashboard.service"

  # enable dashboard # todo need to test
  minikube dashboard --url
fi

if ! minikube status >/dev/null 2>&1 ; then
  export CHANGE_MINIKUBE_NONE_USER=true && minikube start --vm-driver=none
fi

make_service "minikube.service"

echo_debug "If dashboard does not work, you should print this command: minikube dashboard"