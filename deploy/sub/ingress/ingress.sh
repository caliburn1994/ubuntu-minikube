sudo helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
sudo helm repo update
sudo helm install ingress-nginx ingress-nginx/ingress-nginx

#sudo minikube addons enable ingress