git submodule add https://github.com/kubernetes-for-developers/kfd-flask.git training/developers/modules/kfd-flask
git submodule add https://github.com/kubernetes-for-developers/kfd-nodejs.git training/developers/modules/kfd-nodejs
git submodule add https://github.com/kubernetes-for-developers/kfd-celery.git training/developers/modules/kfd-celery

Delete the relevant line from the .gitmodules file.
Delete the relevant section from .git/config.
Run git rm --cached path_to_submodule (no trailing slash).
Commit the superproject.
Delete the now untracked submodule files.


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

watch -n 1 kubectl get pod,service --all-namespaces

eval `minikube docker-env`
docker rmi -f $(docker images -a -q)