sudo minikube start --vm-driver=none

# 🤹  Configuring local host environment ...
#
#❗  The 'none' driver is designed for experts who need to integrate with an existing VM
#💡  Most users should use the newer 'docker' driver instead, which does not require root!
#📘  For more information, see: https://minikube.sigs.k8s.io/docs/reference/drivers/none/
#
#❗  kubectl and minikube configuration will be stored in /root
#❗  To use kubectl or minikube commands as your own user, you may need to relocate them. For example, to overwrite your own settings, run:
#
#    ▪ sudo mv /root/.kube /root/.minikube $HOME
#    ▪ sudo chown -R $USER $HOME/.kube $HOME/.minikube
#
#💡  This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
#🔎  Verifying Kubernetes components...
#    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
#🌟  Enabled addons: storage-provisioner, default-storageclass
#🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
