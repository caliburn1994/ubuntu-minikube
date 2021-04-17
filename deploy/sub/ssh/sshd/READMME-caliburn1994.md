## NOTE

Copy from https://github.com/wiremind/wiremind-helm-charts, because the installation tutorial is not working.

And you can see : 

- https://artifacthub.io/packages/helm/wiremind/sshd
- https://github.com/wiremind/docker-sshd/blob/master/Dockerfile


## How to use


```shell
helm install my-sshd ./sshd
kubectl port-forward --namespace default svc/my-sshd 2222:22 --address 0.0.0.0
```
And then use private key to log-in.
```shell
ssh root@localhost -p 2222
```