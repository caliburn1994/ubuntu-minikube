#!/usr/bin/env bash

SCRIPT_MODULE=deploy
PROJECT_ROOT_PATH="$(echo "${BASH_SOURCE[0]}" | awk -F "/${SCRIPT_MODULE}" '{print $1}')" && source "${PROJECT_ROOT_PATH}/deploy/common.sh"

echo_running
# install
if ! sudo kubectl get service localstack &>/dev/null; then
  sudo helm repo add localstack-repo http://helm.localstack.cloud
  sudo helm upgrade --install localstack localstack-repo/localstack
fi

NODE_PORT=$(sudo kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services localstack)
NODE_IP=$(sudo kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
URL=http://$NODE_IP:$NODE_PORT
cat <<EOF >"${PROJECT_ROOT_PATH}/out/localstack.html"
<meta http-equiv="refresh" content="0; url=${URL}" />
EOF


HOST=$(sudo minikube ip)

# https://docs.docker.com/engine/security/protect-access/
function gen_ca() {
  # public and private keys
  openssl rand -base64 48 >"${PROJECT_ROOT_PATH}/out/docker/passphrase.txt" # random password
  openssl genrsa -aes256 \
    -passout file:"${PROJECT_ROOT_PATH}/out/docker/passphrase.txt" \
    -out "${PROJECT_ROOT_PATH}/out/docker/ca-key.pem" \
    4096

  # ca
  # https://support.comodo.com/index.php?/Knowledgebase/Article/View/792/19/certificate-signing-request-csr-generation---nortel-ssl-accelerator
  Organization="unknown"
  OrganizationalUnit="IT"
  CountryName="CN"
  HOST=$(sudo minikube ip)
  CommonName=${HOST}
  openssl req -new -x509 -days 365 \
    -subj "/C=${CountryName}/O=${Organization}/OU=${OrganizationalUnit}/CN=${CommonName}" \
    -passin file:"${PROJECT_ROOT_PATH}/out/docker/passphrase.txt" \
    -key "${PROJECT_ROOT_PATH}/out/docker/ca-key.pem" \
    -sha256 -out "${PROJECT_ROOT_PATH}/out/docker/ca.pem"
}


echo ${PROJECT_ROOT_PATH}

# CSR
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr

echo subjectAltName = DNS:$HOST,IP:10.10.10.20,IP:127.0.0.1 >> extfile.cnf
echo extendedKeyUsage = clientAuth > extfile-client.cnf


openssl x509 -req -days 365 -sha256 -in client.csr -CA "${PROJECT_ROOT_PATH}/out/docker/ca.pem" -CAkey "${PROJECT_ROOT_PATH}/out/docker/ca-key.pem" \
  -passin file:"${PROJECT_ROOT_PATH}/out/docker/passphrase.txt" \
  -CAcreateserial -out cert.pem -extfile extfile-client.cnf
