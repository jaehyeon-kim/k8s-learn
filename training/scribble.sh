https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.16/

minikube start --memory='20000mb' --cpus=10

## start minikube
minikube start


kubectl apply -f devenv/kube-ops-view/deploy/

# if minikube
http://<minikube-ip>:32000/#scale=2.0

http://192.168.99.100:32000/#scale=2.0

watch -n 1 kubectl get pods,deploy,rs,svc,ns --show-labels

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
# 127.0.0.1:8000
#
kubectl apply -f training/bootcamp/src/pods/db-pod.yml
## check if directory exists in host and mounted in pod
# host - minikube
minikube ssh
sudo su -
ls -alt /var/lib/postgres
# container
kubectl exec -it db sh
ls -alt /var/lib/postgresql/data

kubectl apply -f training/bootcamp/src/pods/multi_container_pod.yml

kubectl exec -it web sh # default nginx
kubectl exec -it web sh -c sync

kubectl logs web -c nginx
kubectl logs web -c sync

kubectl delete -f training/bootcamp/src/pods/

#### 07 Replacation Controllers and Replica Sets
export srcpath=training/bootcamp/src

kubectl config view
kubectl config get-contexts # blank if default
kubectl get ns

kubectl apply -f $srcpath/projects/instavote/instavote-ns.yml

kubectl config set-context \
    $(kubectl config current-context) --namespace=instavote
# Context "minikube" modified.

# deploy to new namespace
kubectl apply -f $srcpath/pods/vote-pod.yml

kubectl get pod vote -o yaml | grep annotations

# --dry-run
kubectl apply -f $srcpath/projects/instavote/dev/vote-rs.yml

# replicaset notes
#   individually editing a pod doesn't update pod <-- should use deployment
#   if a pod is terminated (kubectl delete pod/<name>), a new pod will be created

kubectl delete -f $srcpath/projects/instavote/dev/

#### 08 Service Discovery and Load Balancing

kubectl apply -f $srcpath/projects/instavote/dev/vote-rs.yml
kubectl apply -f $srcpath/projects/instavote/dev/vote-svc.yml

# cluster IP is constant but not Pod IPs
kubectl describe svc vote
# Name:                     vote
# Namespace:                instavote
# Labels:                   role=vote
# Selector:                 role=vote,version=v1
# Type:                     NodePort
# IP:                       10.111.150.233 <- Cluster IP
# Port:                     <unset>  80/TCP
# TargetPort:               80/TCP
# NodePort:                 <unset>  30000/TCP
# Endpoints:                172.17.0.3:80,172.17.0.4:80 <- POD IPs
# Session Affinity:         None
# External Traffic Policy:  Cluster
# Events:                   <none>

minikube service vote --namespace instavote --url
# http://192.168.99.100:30000

## Service Discovery
kubectl exec -it pod/vote-xxx sh
watch ping redis
# FROM: ping bad address 'redis'

kubectl apply -f $srcpath/projects/instavote/dev/redis-deploy.yml
kubectl apply -f $srcpath/projects/instavote/dev/redis-svc.yml

# TO: PING redis (10.107.2.138): 56 data bytes
# voting should work on http://192.168.99.100:30000/

kubectl delete -f $srcpath/projects/instavote/dev/

#### 09 Application Deployments and Updates
kubectl apply -f $srcpath/projects/instavote/dev/

kubectl rollout status deploy/vote
# deployment "vote" successfully rolled out

kubectl scale deploy/vote --replicas=3
# deployment.extensions/vote scaled

## change v1 to v2
kubectl apply -f $srcpath/projects/instavote/dev/vote-deploy.yml
# deployment.apps/vote configured

# both v1 and v2 are kept
kubectl get rs
# NAME                                    DESIRED   CURRENT   READY   AGE     LABELS
# replicaset.extensions/redis-7cd9fd75c   2         2         2       9m50s   app=redis,pod-template-hash=7cd9fd75c,role=redis,tier=back,version=latest
# replicaset.extensions/vote-77bd7ff6c6   2         2         2       2m      app=python,pod-template-hash=77bd7ff6c6,role=vote,version=v2
# replicaset.extensions/vote-cb68b8bb6    0         0         0       9m13s   app=python,pod-template-hash=cb68b8bb6,role=vote,version=v1

kubectl rollout history deploy/vote
# deployment.extensions/vote 
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         <none>

kubectl rollout history deploy/vote --revision=2

kubectl rollout undo deploy/vote --to-revision=2


kubectl logs pod/worker-86f8f46b66-t5d4j

#### 10 ConfigMaps and Secrets

## use by envFrom
kubectl apply -f $srcpath/projects/instavote/dev/vote-cm.yml

kubectl get cm
kubectl describe cm vote

kubectl apply -f $srcpath/projects/instavote/dev/vote-deploy.yml
kubectl apply -f $srcpath/projects/instavote/dev/vote-svc.yml

## use by volume
kubectl create configmap --from-file $srcpath/projects/instavote/config/redis.conf redis

kubectl apply -f $srcpath/projects/instavote/dev/redis-deploy.yml
kubectl apply -f $srcpath/projects/instavote/dev/redis-svc.yml

echo "admin" | base64
# YWRtaW4K
echo "password" | base64
cGFzc3dvcmQK

kubectl apply -f $srcpath/projects/instavote/dev/db-secrets.yml

kubectl apply -f $srcpath/projects/instavote/dev/db-deploy.yml
kubectl apply -f $srcpath/projects/instavote/dev/db-svc.yml

## updates on configmap (and secrets) doesn't make pods to update
## redeploy or update with updated name of them