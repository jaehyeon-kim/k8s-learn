######## Day 1
#### create a cluster with minikube
minikube start \
    --cpus 2 \
    --memory 4096 \
    --kubernetes-version v1.16.0 \
    --insecure-registry 10.0.0.0/24

## addons
minikube addons enable ingress
minikube addons enable registry
minikube addons enable heapster
minikube addons enable dashboard

minikube addons list

minikube dashboard
minikube addons open dashboard
minikube service kubernetes-dashboard -n kube-system

minikube service list

minikube addons open heapster

## logs
minikube logs

## use local docker daemon
eval `minikube docker-env`
docker ps

# additional tool to debug
minikube ssh toolbox

minikube ssh

#### explorer cluster
kubectl get node
kubectl describe node minikube

kubectl -n kube-system get pod

kubectl -n kubernetes-dashboard get pod
kubectl -n kubernetes-dashboard describe pod kubernetes-dashboard-57f4cb4545-mxzn9
kubectl -n kubernetes-dashboard get pod kubernetes-dashboard-57f4cb4545-mxzn9 -o yaml

#### deploy an app
eval `minikube docker-env`

## expose app in minikube
docker run --name first-app -d -p 8000:80 first-app:v1
curl $(minikube ip):8000
curl `minikube ip`:8000

## expose as k8s service
kubectl create -f kubernetes/
# deployment.apps/first-app created
# service/first-app created

# nodePort: 30000
curl $(minikube ip):30000

watch -n 1 kubectl get pods,deploy,rs,svc,ns --show-labels

######## Day 2
#### kubernetes manifests
# https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.16/
kubectl api-versions

#### kubectl config
kubectl config view

# cat ~/.kube/config

# apiVersion: v1
# clusters:
# - cluster:
#     certificate-authority: /home/jaehyeon/.minikube/ca.crt
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
#     client-certificate: /home/jaehyeon/.minikube/client.crt
#     client-key: /home/jaehyeon/.minikube/client.key

# context --> a cluster and a user are mapped together, optionally set namespace
kubectl config set-context system --cluster=minikube --user=minikube --namespace=kube-system
kubectl config use-context system

kubectl config set-context \
    $(kubectl config current-context) --namespace=<ns-name>

#### helm for package management
# https://hub.kubeapps.com/
# https://github.com/helm/charts

# helm init not working in minikube with kubernetes v1.16.0
# download image manually
eval $(minikube docker-env)
docker pull gcr.io/kubernetes-helm/tiller:v2.14.3

# update manifests
helm init --service-account tiller \
    --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml \
    | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' > tiller.yml

kubectl apply -f tiller.yml

