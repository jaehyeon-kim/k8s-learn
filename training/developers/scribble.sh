minikube start \
    --cpus 2 \
    --memory 4096 \
    --kubernetes-version v1.15.4 \
    --insecure-registry 10.0.0.0/24s

minikube status
kubectl cluster-info
kubectl version
kubectl get componentstatuses
kubectl get events

kubectl get pods --all-namespaces
kubectl get services --all-namespaces

watch -n 1 kubectl get pod,rs,deployment,service --all-namespaces

eval `minikube docker-env`
docker rmi -f $(docker images -a -q)

## if use local images in minikube
cd apps/kfd-flask
git fetch --tags
git checkout tags/first_container

eval `minikube docker-env`
docker build -t flask:0.1.0 .

# create deployment
# if deployment not working, --generator=run-pod/v1
kubectl run flask \
    --image=quay.io/kubernetes-for-developers/flask:latest \
    --port=5000 --save-config

## expose pod
# port forwarding
kubectl port-forward flask-66dc5c9d7f-zmz6c 5000:5000

curl localhost:5000

# kube proxy
kubectl proxy

curl localhost:8001/api/v1/namespaces/default/pods/flask-66dc5c9d7f-zmz6c
