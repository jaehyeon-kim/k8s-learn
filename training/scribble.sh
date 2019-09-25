https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.16/

minikube start --memory='20000mb' --cpus=10

## start minikube
minikube start


kubectl apply -f devenv/kube-ops-view/deploy/

# if minikube
http://<minikube-ip>:32000/#scale=2.0

http://192.168.99.100:32000/#scale=2.0

watch -n 1 kubectl get pods,deploy,rs,svc --show-labels

minikube dashboard

#### 06 Pods
kubectl apply -f training/bootcamp/src/pods/vote-pod.yml

kubectl get pods
kubectl describe pods vote
kubectl logs vote # -f vote
kubectl exec -it vote sh
kubectl edit pod vote
kubectl get pod -o yaml
# ipaddr
# hostname

# if local
kubectl port-forward vote 8000:80

#
kubectl apply -f training/bootcamp/src/pods/db-pod.yml
# check if directory exists in host and mounted in pod

kubectl apply -f training/bootcamp/src/pods/multi_container_pod.yml

kubectl exec -it web sh # default nginx
kubectl exec -it web sh -c sync

kubectl logs web -c nginx
kubectl logs web -c sync

#### 07 Replacation Controllers and Replica Sets
export srcpath=training/bootcamp/src

kubectl config view
kubectl config get-contexts # blank if default
kubectl get ns

kubectl apply -f $srcpath/projects/instavote/instavote-ns.yml

kubectl config set-context $(kubectl config current-context) --namespace=instavote
# Context "minikube" modified.

# deploy to new namespace
kubectl apply -f $srcpath/pods/vote-pod.yml

kubectl get pod vote -o yaml | grep annotations

# --dry-run
kubectl apply -f $srcpath/projects/instavote/dev/vote-rs.yml

# replicaset notes
#   individually editing a pod doesn't update pod <-- should use deployment
#   if a pod is terminated (kubectl delete pod/<name>), a new pod will be created