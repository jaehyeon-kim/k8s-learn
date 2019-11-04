watch -n 1 kubectl get po,rc,svc -o wide --show-labels

###### ch02
kubectl run kubia --image=luksa/kubia --port=8080 --generator=run/v1

kubectl get po

# minikube doesn't support LoadBalancer, use NodePort instead
kubectl expose rc kubia --type=LoadBalancer --name kubia-http
kubectl expose rc kubia --type=NodePort --name kubia-http

kubectl get svc

kubectl scale rc kubia --replicas=3

###### ch03 Pod
kubectl get po kubia-5gf9m -o yaml

# check resource and fields
kubectl explain po
kubectl explain po.spec

kubectl create -f inaction/ch03/kubia-manual.yaml

kubectl get po kubia-manual -o yaml # -o json

kubectl logs kubia-manual
# Kubia server starting...

#### port forwaring
kubectl port-forward kubia-manual 8888:8080
# Forwarding from 127.0.0.1:8888 -> 8080
# Forwarding from [::1]:8888 -> 8080

curl localhost:8888
# You've hit kubia-manual

#### labels
kubectl create -f inaction/ch03/kubia-manual-with-labels.yaml

kubectl get po --show-labels
kubectl get po -L creation_method,env

## add label to existing resource
kubectl label po kubia-manual creation_method=manual
## change label: --overwrite
kubectl label po kubia-manual-v2 env=debug --overwrite
## filter using label selector
kubectl get po -l creation_method=manual
kubectl get po -l creation_method!=manual
kubectl get po -l env
kubectl get po -l '!env'
kubectl get po -l 'env in (prod,debug)'
kubectl get po -l 'env notin (prod,debug)'

kubectl get po -l creation_method=manual,env=debug

## label + nodeSelector
kubectl label node <node-name> gpu=true
kubectl get nodes -l gpu=true

```
apiVersion: v1
kind: Pod
metadata:
  name: kubia-gpu
spec:
  nodeSelector:
    gpu: "true"
```

## annotations
# more info than labels, no something like labelSelector
# usually alpha/beta features to annotations, later turns to fields
# for sharing information

kubectl annotate pod kubia-manual mycompany.com/someannotation="foo bar"

## namespaces
kubectl get ns

kubectl get po -n kube-system

kubectl create -f inaction/ch03/custom-namespace.yaml
kubectl create -f inaction/ch03/kubia-manual.yaml -n custom-namespace

kubectl get po -n custom-namespace

#TIP
alias kcd='kubectl config set-context $(kubectl config current-context) --namespace'

## deletion
kubectl delete po pod1
kubectl delete po pod1 pod2
kubectl delete po -l creation_method=manual

# resources in custom-namespace will also be deleted
kubectl delete ns custom-namespace
# delete all pods in current namespace
kubectl delete po --all

# all resources will be deleted but not some (eg secrets)
kubectl delete all --all

###### 04 RC/RS

#### liveness prob
# HTTP GET
# TCP socket
# Exec prob

kubectl create -f inaction/ch04/kubia-liveness-prob.yaml --save-config

# pod updates may not change fields other than 
#   `spec.containers[*].image`, 
#   `spec.initContainers[*].image`, 
#   `spec.activeDeadlineSeconds` or 
#   `spec.tolerations` (only additions to existing tolerations)

kubectl describe po kubia-liveness
# Liveness: http-get http://:8080/ delay=0s timeout=1s period=10s #success=1 #failure=3

kubectl explain po.spec.containers.livenessProbe

kubectl logs kubia-liveness
kubectl logs kubia-liveness --previous

#### RC
kubectl create -f inaction/ch04/kubia-rc.yaml

# pod no longer managed by RC
kubectl label po kubia-mgxg4 type=special app=foo --overwrite

# RC allows to change label selector

# adding a new label to pod template doesn't change existing pod
# new label will be added to new pod
KUBE_EDITOR="nano" kubectl edit rc kubia

## horizontally scaling
# change replicas to 10
KUBE_EDITOR="nano" kubectl edit rc kubia

kubectl scale rc kubia --replicas=3

# delete
kubectl delete rc kubia
kubectl delete rc kubia --cascade=false

#### RS
## RS has more expressive pod selectors
# selector:
#   matchLabels:
#     app: kubia

# expressions - In, NotIn, Exists, DoesNotExists
# selector:
#   matchExpressions:
#     - key: app
#       operator: IN
#       values:
#         - kubia


kubectl explain replicaset

## unmanaged pod by RC now managed by RS
kubectl delete rc kubia --cascade=false
kubectl create -f inaction/ch04/kubia-replicaset.yaml