docker network create --driver bridge  \
--gateway="192.168.0.1" \
--subnet="192.168.0.0/24" \
my-minikube-network