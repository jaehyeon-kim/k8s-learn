## Minikube and Kubectl Installation and Basic Operations

### Installation

```bash
## https://computingforgeeks.com/how-to-install-minikube-on-ubuntu-18-04/

#### update system
sudo apt-get update \
    && sudo apt-get -y install apt-transport-https
# sudo apt-get -y upgrade

#### install virtualbox hypervisor
sudo apt install -y virtualbox virtualbox-ext-pack

#### install minikube
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
    && chmod +x minikube-linux-amd64 \
    && sudo mv minikube-linux-amd64 /usr/local/bin/minikube

## check
minikube version
# minikube version: v1.4.0
# commit: 7969c25a98a018b94ea87d949350f3271e9d64b6

#### install kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt -y install kubectl

# apt-get install --only-upgrade <packagename>

## check
kubectl version -o json 
# {
#   "clientVersion": {
#     "major": "1",
#     "minor": "16",
#     "gitVersion": "v1.16.0",
#     "gitCommit": "2bd9643cee5b3b3a5ecbd3af49d09018f0773c77",
#     "gitTreeState": "clean",
#     "buildDate": "2019-09-18T14:36:53Z",
#     "goVersion": "go1.12.9",
#     "compiler": "gc",
#     "platform": "linux/amd64"
#   }
# }

#### install helm
* https://www.digitalocean.com/community/tutorials/how-to-install-software-on-kubernetes-clusters-with-the-helm-package-manager
* https://helm.sh/docs/using_helm/#installing-helm

curl -L https://git.io/get_helm.sh | sudo bash

#### install kubectx and kubens
wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx \
    && chmod +x kubectx \
    && sudo mv kubectx /usr/local/bin/kubectx

wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens \
    && chmod +x kubens \
    && sudo mv kubens /usr/local/bin/kubens

#### install kubetail
wget https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail \
    && chmod +x kubetail \
    && sudo mv kubetail /usr/local/bin/kubetail

```
### Basic operations

```bash
## start minikube
minikube start

# --kubernetes-version='v1.16.0'
# --memory='2000mb'
# --cpus=2
# --disk-size='20000mb'
# --mount=false
# --mount-string='/home/<user>:/minikube-host'

kubectl cluster-info
# Kubernetes master is running at https://192.168.99.100:8443
# KubeDNS is running at https://192.168.99.100:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

# cat ~/.minikube/machines/minikube/config.json

kubectl config view
# apiVersion: v1
# clusters:
# - cluster:
#     certificate-authority: /home/<user>/.minikube/ca.crt
#     server: https://192.168.99.100:8443
#   name: minikube
# contexts:
# - context:
#     cluster: minikube
#     user: minikube
#   name: minikube
# current-context: minikube
# kind: Config
# preferences: {}
# users:
# - name: minikube
#   user:
#     client-certificate: /home/<user>/.minikube/client.crt
#     client-key: /home/<user>/.minikube/client.key

kubectl get nodes
# NAME       STATUS   ROLES    AGE     VERSION
# minikube   Ready    master   6m20s   v1.15.2

## SSH
minikube ssh
# inside node
sudo su -

## Setup docker environment
# minikube docker-env
# export DOCKER_TLS_VERIFY="1"
# export DOCKER_HOST="tcp://192.168.99.100:2376"
# export DOCKER_CERT_PATH="/Users/gouravshah/.minikube/certs"
# export DOCKER_API_VERSION="1.23"

eval $(minikube docker-env)
docker ps

minikube stop

minikube delete
```

### Kubernetes dashboard

```bash
minikube addons list
# - addon-manager: enabled
# - dashboard: disabled
# - default-storageclass: enabled
# - efk: disabled
# - freshpod: disabled
# - gvisor: disabled
# - heapster: disabled
# - ingress: disabled
# - logviewer: disabled
# - metrics-server: disabled
# - nvidia-driver-installer: disabled
# - nvidia-gpu-device-plugin: disabled
# - registry: disabled
# - registry-creds: disabled
# - storage-provisioner: enabled
# - storage-provisioner-gluster: disabled

minikube dashboard --url
# http://127.0.0.1:46663/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/#!/overview
```

### Resources
* [kubernetes.io - tutorials](https://kubernetes.io/docs/tutorials/)
* [kubernetes.io - install-minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
* [How to Install Minikube on Ubuntu 18.04](https://computingforgeeks.com/how-to-install-minikube-on-ubuntu-18-04/)