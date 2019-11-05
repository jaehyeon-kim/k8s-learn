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

kubectl delete rs kubia --cascade=false
kubectl create -f inaction/ch04/kubia-replicaset-matchexpressions.yaml

#### DaemonSet
# pod on each node - scheduler not necessary

kubectl create -f inaction/ch04/ssh-monitor-daemonset.yaml
# pod created as appropriate label added
kubectl label node minikube disk=ssd
# pod terminated but not daemonset itself
kubectl label node minikube disk-

#### Job
# pods managed by jobs are rescheduled until they finish successfully
# although completed, pods not deleted
kubectl create -f inaction/ch04/exporter.yaml

kubectl create -f inaction/ch04/multi-completion-batch-job.yaml

# scale not working?? --> update parallelism
# kubectl scale job multi-completion-batch-job --replicas 3

#### CronJob
# use --save-config for changing config with kubectl apply
kubectl create -f inaction/ch04/cronjob.yaml --save-config

###### Ch05 SVC
#### <-- How services can be consumed by pods
## kubectl apply -f ... or kubectl create -f ... --save-config
kubectl apply -f inaction/ch04/kubia-replicaset.yaml
kubectl apply -f inaction/ch05/kubia-svc.yaml

# cluster ip: 10.111.220.163 <-- accessible inside cluster
kubectl exec kubia-56q4t -- curl -s http://10.111.220.163

# sessionAffinity: None or ClientIP
#   - if clientIP, requests from same clientIP goes to same pod

## multiple ports
# apiVersion: v1
# kind: Service
# metadata:
#   name: kubia
# spec:
#   selector:
#     app: kubia
#   ports:
#     - name: http
#       port: 80
#       targetPort: 8080
#     - name: https
#       port: 443
#       targetPort: 8443

## named ports
kubectl apply -f inaction/ch05/kubia-named-ports.yaml

## service ip and ports by environment variables
kubectl exec kubia-56q4t env
# KUBIA_PORT=tcp://10.111.220.163:80
# KUBIA_PORT_80_TCP=tcp://10.111.220.163:80
# KUBIA_PORT_80_TCP_PROTO=tcp
# KUBIA_SERVICE_PORT=80

## service DNS
kubia.default.svc.cluster.local
kubia.dafault
kubia # if in same namespace

kubectl exec kubia-56q4t cat /etc/resolv.conf
# nameserver 10.96.0.10
# search default.svc.cluster.local svc.cluster.local cluster.local
# options ndots:5

kubectl exec -it kubia-56q4t bash
# root@kubia-56q4t:/# curl http://kubia.default.svc.cluster.local
# root@kubia-56q4t:/# curl http://kubia.default
# root@kubia-56q4t:/# curl http://kubia

## service's cluster IP is a virtual IP - can curl but not ping

## services don't link to pods directly but with endpoints
# pod selector defined in service manifest is used to build a list of IPs and ports
# then the list is stored in endpoints resource
# when client makes a request, service proxy selects one of them and redirects
kubectl get endpoints kubia
# NAME    ENDPOINTS                                         AGE
# kubia   172.17.0.6:8080,172.17.0.7:8080,172.17.0.8:8080   9m46s

## service can be created without pod selector
## endpoints resource needs to provide manual endpoints
## useful eg) linking external services
## service and endpoints name should match

#### <-- How to expose services
### NodePort <- service will be accessible though each of cluster nodes
### LoadBalancer
# externalTrafficPolicy: Local <- served by pod within the node
# if pod not exists, no forwarding
# if pods not evenly distributed, uneven load distribution
# but without no network hop, client IP is preserved
### Ingress

kubectl apply -f inaction/ch05/kubia-svc-nodeport.yaml

# kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'

curl http://172.28.175.26:30123