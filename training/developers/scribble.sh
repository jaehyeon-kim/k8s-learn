minikube start \
    --cpus 2 \
    --memory 4096 \
    --kubernetes-version v1.15.4 \
    --insecure-registry 10.0.0.0/24

minikube status
kubectl cluster-info
kubectl version
kubectl get componentstatuses
kubectl get events

kubectl get pods --all-namespaces
kubectl get services --all-namespaces

watch -n 1 kubectl get pod,service --all-namespaces

eval `minikube docker-env`
docker rmi -f $(docker images -a -q)