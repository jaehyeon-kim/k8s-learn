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

inaction/ch05/external-service.yaml
inaction/ch05/external-service-endpoints.yaml
inaction/ch05/external-service-externalname.yaml

#### <-- How to expose services
### NodePort <- service will be accessible though each of cluster nodes
### LoadBalancer
# externalTrafficPolicy: Local <- served by pod within the node
# if pod not exists, no forwarding
# if pods not evenly distributed, uneven load distribution
# but without no network hop, client IP is preserved
### Ingress

### NodePort
kubectl apply -f inaction/ch05/kubia-svc-nodeport.yaml

# kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'

curl http://172.28.175.26:30123

### LoadBalancer
inaction/ch05/kubia-svc-loadbalancer.yaml

curl http://<external-ip>:30123

### Ingress
minikube addons list
minikube addons enable ingress

kubectl get po --all-namespaces

kubectl get po --all-namespaces | grep ingress
# kube-system   nginx-ingress-controller-57bf9855c8-55m75    1/1     Running   0          65s


kubectl apply -f inaction/ch04/kubia-replicaset.yaml
kubectl apply -f inaction/ch05/kubia-svc-nodeport.yaml
kubectl apply -f inaction/ch05/kubia-ingress.yaml

sudo cat /etc/hosts
# > 172.28.175.26   kubia.example.com

curl http://kubia.example.com -v
# * Rebuilt URL to: http://kubia.example.com/
# *   Trying 172.28.175.26... <-- 1. DNS server (or local operating system) returns IP of kubia.example.com
# * TCP_NODELAY set
# * Connected to kubia.example.com (172.28.175.26) port 80 (#0)
# > GET / HTTP/1.1
# > Host: kubia.example.com <-- 2. Send HTTP request to ingress controller specifiying Host header
# > User-Agent: curl/7.58.0
# > Accept: */*
# >
# < HTTP/1.1 200 OK <-- 3. ingress resource check endpoints and forward traffic to one of the pods
# < Server: openresty/1.15.8.1
# < Date: Wed, 06 Nov 2019 20:20:10 GMT
# < Transfer-Encoding: chunked
# < Connection: keep-alive
# <
# You've hit kubia-88x6f
# * Connection #0 to host kubia.example.com left intact

## HTTPS
openssl genrsa -out inaction/ch05/tls/tls.key 2048
openssl req -new -x509 -key inaction/ch05/tls/tls.key \
  -out inaction/ch05/tls/tls.cert -days 360 -subj /CN=kubia.example.com

kubectl create secret tls tls-secret \
  --cert=inaction/ch05/tls/tls.cert \
  --key=inaction/ch05/tls/tls.key

kubectl apply -f inaction/ch05/kubia-ingress-tls.yaml

curl -k -v https://kubia.example.com/kubia
# ...
# * Server certificate:
# *  subject: CN=kubia.example.com
# *  start date: Nov  6 20:32:21 2019 GMT
# *  expire date: Oct 31 20:32:21 2020 GMT
# *  issuer: CN=kubia.example.com
# *  SSL certificate verify result: self signed certificate (18), continuing anyway.
# ...

#### readiness prob
# HTTP GET
# TCP socket
# Exec prob

## unlike liveness prob, pod not killed

kubectl apply -f inaction/ch04/kubia-replicaset-readinessprob.yaml

kubectl exec kubia-ftfkx -- touch /var/ready

#### headless service
kubectl apply -f inaction/ch04/kubia-replicaset.yaml
kubectl apply -f inaction/ch05/kubia-headless.yaml

kubectl run dnsutils --image=tutum/dnsutils \
  --generator=run-pod/v1 --command -- sleep infinity

kubectl exec dnsutils nslookup kubia-headless
# Server:         10.96.0.10
# Address:        10.96.0.10#53

# Name:   kubia-headless.default.svc.cluster.local
# Address: 172.17.0.9
# Name:   kubia-headless.default.svc.cluster.local
# Address: 172.17.0.8
# Name:   kubia-headless.default.svc.cluster.local
# Address: 172.17.0.7

###### ch06
#### volume types
# emptyDir
# hostPath
# gitRepo
# nfs
# configMap, secret, downwardAPI
# persistentVolumeClaim
# gcePersistentDisk
# cinder, cephfs, iscsi, flocker, glusterfs, quobyte, rbd, \
#      flexVolume, vsphere-Volume, photonPersistentDisk, scaleIO

#### emptyDir
kubectl apply -f inaction/ch06/fortune-pod.yaml
kubectl port-forward fortune 8080:80

kubectl exec -it fortune -c web-server sh
cat /usr/share/nginx/html/index.html

# volumes:
#   - name: html
#     emptyDir: {} # {} in filesystem or Memory can also be specified

#### gitRepo
# gitRepo is only one time cloning
# to sync or to access private repo, consider sidecar
kubectl apply -f inaction/ch06/gitrepo-volume-pod.yaml

#### hostPath
kubectl describe po etcd-minikube -n kube-system
# ...
# Volumes:
#   etcd-certs:
#     Type:          HostPath (bare host directory volume)
#     Path:          /var/lib/minikube/certs/etcd
#     HostPathType:  DirectoryOrCreate
#   etcd-data:
#     Type:          HostPath (bare host directory volume)
#     Path:          /var/lib/minikube/etcd
#     HostPathType:  DirectoryOrCreate
# ...

#### PersistentVolumes and PersistentVolumeClaims
# RWO—ReadWriteOnce — Only a single node can mount the volume for reading and writing.
# ROX—ReadOnlyMany — Multiple nodes can mount the volume for reading.
# RWX—ReadWriteMany — Multiple nodes can mount the volume for both reading and writing.


kubectl apply -f inaction/ch06/mongodb-pv-hostpath.yaml
kubectl apply -f inaction/ch06/mongodb-pvc.yaml
kubectl apply -f inaction/ch06/mongodb-rs-pvc.yaml

kubectl exec -it mongodb-j5khk mongo
# use mystore
# db.foo.insert({name: 'foo'})
# db.foo.find()
# { "_id" : ObjectId("5dc483fabedaad5a20a415f4"), "name" : "foo" }

kubectl delete po mongodb-j5khk

kubectl exec -it mongodb-h8l8q mongo
# use mystore
# db.foo.find()
# { "_id" : ObjectId("5dc483fabedaad5a20a415f4"), "name" : "foo" }

#### PV
## persistentVolumeReclaimPolicy: Retain
# PV status: Avaialble (pv created) -- Bound (pvc created) -- Releases (pvc deleted)
# when released, cannot be bound to another claim even with the same name

## persistentVolumeReclaimPolicy: Recycle
# contents deleted when bound claim deleted, can be used by other pods

## persistentVolumeReclaimPolicy: Delete
# underlying storage is deleted

## reclaim policy can be changed to existing volumes

#### StorageClass
# PV - no namespace
# PVC - namespace
# SC - no namespace

kubectl apply -f inaction/ch06/storageclass-fast-hostpath.yaml
kubectl apply -f inaction/ch06/mongodb-pvc-dp.yaml

kubectl describe pv pvc-8190a91b-c240-4539-93ce-c6d03cfb5c11
# Name:            pvc-8190a91b-c240-4539-93ce-c6d03cfb5c11
# ...
# Source:
#     Type:          HostPath (bare host directory volume)
#     Path:          /tmp/hostpath-provisioner/pvc-8190a91b-c240-4539-93ce-c6d03cfb5c11
#     HostPathType:


kubectl get sc standard -o yaml
# apiVersion: storage.k8s.io/v1
# kind: StorageClass
# metadata:
#   annotations:
#     storageclass.kubernetes.io/is-default-class: "true"
#   creationTimestamp: "2019-10-21T06:06:46Z"
#   labels:
#     addonmanager.kubernetes.io/mode: EnsureExists
#   name: standard
#   resourceVersion: "365"
#   selfLink: /apis/storage.k8s.io/v1/storageclasses/standard
#   uid: f325ffb6-12b6-470f-ba6e-4cb098d5186d
# provisioner: k8s.io/minikube-hostpath
# reclaimPolicy: Delete
# volumeBindingMode: Immediate

### If PVC 
### storageClassName: "", it's set to bound to an existing PV
### no storageClassName, bound to standard (default) storage class
### storageClassName: "fast" <-- bound to a certain storage class named fast


###### ch07
## configuration options
##    command line arguments
##    environment variables
##    mount config files via volume

# ENTRYPOINT ["node", "app.js"]
#     PID 1 ==> node app.js
# ENTRYPOINT node app.js 
#     PID 1 /bin/sh -c node app.js
#     PID 7 node app.js

## command line arguments
# apiVersion: v1
# kind: Pod
# metadata: 
#   name: kubia
# spec:
#   containers:
#     - image: some/image
#       name: someimage
#       command: ["/bin/command"] <-- ENTRYPOINT
#       args: ["arg1", "arg2", "arg3"] <-- CMD
#    OR args:
#         - arg1
#         - arg2
#         - arg3

kubectl apply -f inaction/ch07/fortune-pod-args.yaml

## environment variables <- better with ConfigMap as values don't need to be hard-coded
# ...
# env:
#   - name: INTERVAL
#     value: "30"
#   - name: FIRST_VAR
#     value: "foo"
#   - name: SECOND_VAR
#     value: "$(FIRST_VAR)bar"
#   - args: ["$(FIRST_VAR)"]
# ...

kubectl apply -f inaction/ch07/fortune-pod-env.yaml

#### values of ConfigMap can be used as env vars or volume mount
## from key-value pairs
kubectl create cm myconfig --from-literal=one=two --from-literal=foo=bar
kubectl create cm myconfig --from-file=config-file.conf --from-file=customkey=config-file.conf
kubectl create cm myconfig --from-file=/path/to/dir
kubectl create cm myconfig \
  --from-file=foo.json \
  --from-file=bar=foobar.conf \
  --from-file=config-opts/ \
  --from-literal=some=thing

kubectl create cm fortune-config --from-literal=sleep-interval=25

# ...
# env:
#   - name: INTERVAL
#     valueFrom:
#       configMapKeyRef:
#         optional: false # or true
#         name: fortune-config
#         key: sleep-interval
# envFrom: # everything with CONFIG_ prefix
#   - profix: CONFIG_
#     configMapRef:
#       name: myconfig
# args: ["$(INTERVAL)"]
# ...

# invalid key (eg FOO-BAR) is skipped

kubectl create cm fortune-config --from-file=inaction/ch07/configmap-files
# kubectl apply -f inaction/ch07/fortune-config-cm1.yaml

kubectl apply -f inaction/ch07/fortune-pod-env-configmap.yaml


kubectl apply -f inaction/ch07/fortune-pod-configmap-volume.yaml

kubectl port-forward fortune-configmap-volume 8080:80

curl -H "Accept-Encoding: gzip" -I localhost:8080
# HTTP/1.1 200 OK
# Server: nginx/1.17.5
# Date: Sun, 10 Nov 2019 21:45:35 GMT
# Content-Type: text/html
# Last-Modified: Sun, 10 Nov 2019 21:45:32 GMT
# Connection: keep-alive
# ETag: W/"5dc884fc-102"
# Content-Encoding: gzip

kubectl exec fortune-configmap-volume -c web-server ls /etc/nginx/conf.d
# my-nginx-config.conf
# sleep-interval

# - image: nginx:alpine
#   name: web-server
#   volumeMounts:
#   - name: config
#     mountPath: /etc/nginx/conf.d
#   - name: configItem
#     mountPath: /etc/nginx/conf.d <- only gzip.conf exists
#   - name: configItem
#     mountPath: /etc/something.conf
#     subPath: gzip.conf <- add gzip.conf to /etc/something.conf while keeping existing files
# volumes:
# - name: config <-- all items in config map
#   configMap:
#     name: fortune-config
# - name: configItem
#   configMap: <-- specific items in config map
#     name: fortune-config
#     items:
#       - key: my-nginx-config.conf
#         path: gzip.conf

## file permission on volume - default 644 (-rw-r—r--)
# volumes:
#   - name: config
#     configMap:
#       name: fortune-config
#       defaultMode: "6600" <- can be changed

## changes in config map, mounted as volume updates referenced files but may take up to 1 minute


# check default secret
kubectl run -it --rm busybox --image=busybox --restart=Never -- \
  sh -c "ls /var/run/secrets/kubernetes.io/serviceaccount/"

openssl genrsa -out inaction/ch07/fortune-https/https.key 2048
openssl req -new -x509 -key inaction/ch07/fortune-https/https.key\
  -out inaction/ch07/fortune-https/https.cert -days 3650 \
  -subj /CN=www.kubia-example.com

echo bar > inaction/ch07/fortune-https/foo

kubectl create secret generic fortune-https \
  --from-file=inaction/ch07/fortune-https

# kubectl create secret generic fortune-https \
#   --from-file=inaction/ch07/fortune-https/https.key \
#   --from-file=inaction/ch07/fortune-https/https.cert \
#   --from-file=inaction/ch07/fortune-https/foo

## secret values are Base64-encoded, string can be added in yaml though
apiVersion: v1
kind: Secret
metadata:
  name: fortune-https
stringData:
  foo: plain-text
data:
  https.certs: XXX
  https:key: XXX


kubectl create cm fortune-config --from-file=inaction/ch07/configmap-files
kubectl create secret generic fortune-https --from-file=inaction/ch07/fortune-https
kubectl apply -f inaction/ch07/fortune-pod-https.yaml

kubectl port-forward fortune-https 8443:443
curl https://localhost:8443 -k

## secret volumes are mounted as in-memory filesystem
kubectl exec fortune-https -c web-server -- mount | grep certs
tmpfs on /etc/nginx/certs type tmpfs (ro,relatime)

## secret referred as env var
## not a good practice as app may expose env vars to app log
# env:
#   - name: FOO_SECRET
#     valueFrom:
#       secretKeyRef:
#         name: fortune-https
#         key: foo

## if docker-registry, .dockercfg will be created
## no volume but include it's name in manifest
kubectl create secret docker-registry mydockerhubsecret \
  --docker-username=myusername --docker-password=mypassword \
  --docker-email=my.email@provider.com

# apiVersion: v1
# kind: Pod
# metadata:
# name: private-pod
# spec:
# imagePullSecrets:
#   - name: mydockerhubsecret
# containers:
#   - image: username/private:tag
# name: main

###### ch08

#### Downward API
## following info is passed to containers
## most items via environment vars or downward api
## but labels and annotations only via downward api
# The pod’s name
# The pod’s IP address
# The namespace the pod belongs to
# The name of the node the pod is running on
# The name of the service account the pod is running under
# The CPU and memory requests for each container
# The CPU and memory limits for each container
# The pod’s labels
# The pod’s annotations

minikube addons enable metrics-server

### set limits.memory not working
kubectl apply -f inaction/ch08/downward-api-env.yaml

kubectl exec downward env
# HOSTNAME=downward
# CONTAINER_MEMORY_LIMIT_KIBIBYTES=65536
# POD_NAME=downward
# POD_NAMESPACE=default
# POD_IP=172.17.0.6
# NODE_NAME=minikube
# CONTAINER_CPU_REQUEST_MILLICORES=15

# downward api as volume
# - only works for labels and annotations

# volumes defined by pod level, not container level
# add containerName for requests/limists
# volumes:
#   - name: downward
#     downwardAPI:
#       items:
#         - path: podName
#           fieldRef:
#             fieldPath: metadata.name
#         - path: containerCpuRequestMilliCores
#           resourceFieldRef:
#             containerName: main
#             resource: requests.cpu
#             divisor: 1m

# with volume, a container's requests/limits can be passed into another
# with env var, its own requets/limites can only be passed

kubectl apply -f inaction/ch08/downward-api-volume.yaml

kubectl exec downward -- ls -alt /etc/downward

kubectl exec downward cat /etc/downward/labels
kubectl exec downward cat /etc/downward/annotations

#### k8s API server
kubectl proxy
# Starting to serve on 127.0.0.1:8001

### loop through hierarchy of API server
curl localhost:8001
# {
#   "paths": [
#     "/api",
#     "/api/v1",
#     "/apis",
#     "/apis/",
#     ...
#     "/apis/apps",
#     "/apis/apps/v1",
#     ...
#     "/apis/batch",
#     "/apis/batch/v1",
#     "/apis/batch/v1beta1"
#   ]
# }

curl localhost:8001/apis/batch
# {
#   "kind": "APIGroup",
#   "apiVersion": "v1",
#   "name": "batch",
#   "versions": [
#     {
#       "groupVersion": "batch/v1",
#       "version": "v1"
#     },
#     {
#       "groupVersion": "batch/v1beta1",
#       "version": "v1beta1"
#     }
#   ],
#   "preferredVersion": {
#     "groupVersion": "batch/v1",
#     "version": "v1"
#   }
# }

curl localhost:8001/apis/batch/v1
# {
#   "kind": "APIResourceList",
#   "apiVersion": "v1",
#   "groupVersion": "batch/v1",
#   "resources": [
#     {
#       "name": "jobs",
#       "singularName": "",
#       "namespaced": true,
#       "kind": "Job",
#       "verbs": [
#         "create",
#         "delete",
#         "deletecollection",
#         "get",
#         "list",
#         "patch",
#         "update",
#         "watch"
#       ],
#       "categories": [
#         "all"
#       ],
#       "storageVersionHash": "mudhfqk/qZY="
#     },
#     {
#       "name": "jobs/status",
#       "singularName": "",
#       "namespaced": true,
#       "kind": "Job",
#       "verbs": [
#         "get",
#         "patch",
#         "update"
#       ]
#     }
#   ]
# }

curl localhost:8001/apis/batch/v1/jobs
# {
#   "kind": "JobList",
#   "apiVersion": "batch/v1",
#   "metadata": {
#     "selfLink": "/apis/batch/v1/jobs",
#     "resourceVersion": "3780"
#   },
#   "items": [
#     {
#       "metadata": {
#         "name": "my-job",
#         "namespace": "default",
#   ...
# }

## get a specific job
curl localhost:8001/apis/batch/v1/namespaces/default/jobs/my-job
# same output to kubectl get job my-job -o json
# {
#   "kind": "Job",
#   "apiVersion": "batch/v1",
#   "metadata": {
#     "name": "my-job",
#     "namespace": "default",
#   ...
# }

#### accessing API server inside pod
kubectl apply -f inaction/ch08/curl.yaml

kubectl exec -it curl bash

## check env to access by ip and port
env | grep KUBERNETES_SERVICE
# KUBERNETES_SERVICE_PORT=443
# KUBERNETES_SERVICE_HOST=10.96.0.1
# KUBERNETES_SERVICE_PORT_HTTPS=443

## or use DNS
curl https://kubernetes # -k if avoid SSL cert verification

# or
export CURL_CA_BUNDLE=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
export TOKEN=$(cat /var/run/secrets//kubernetes.io/serviceaccount/token)

curl -H "Authorization: Bearer $TOKEN" https://kubernetes

# If you’re using a Kubernetes cluster with RBAC enabled, the service account may not
# be authorized to access (parts of) the API server.... 
# For now, the simplest way to allow you to query the API server is to work around RBAC by running the following command:
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --group=system:serviceaccounts

NS=$(cat /var/run/secrets//kubernetes.io/serviceaccount/namespace)
curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/$NS/pods

## kube proxy in ambassador
kubectl apply -f inaction/ch08/curl-with-ambassador.yaml

kubectl exec -it curl-with-ambassador -c main bash

curl localhost:8001
curl localhost:8001/api/v1/namespaces/default/pods

## python client library
# https://github.com/kubernetes-client/python

# minikube start --extra-config=apiserver.Features.Enable-SwaggerUI=true

###### ch09

## blue-green deployment
## service points to old pods while new pods are created
## once new pods are created, points to them
## kubectl set selector

## rolling update with rc
kubectl apply -f inaction/ch09/kubia-rc-and-service-v1.yaml

# while true; do curl http://172.28.175.25:30000; sleep 1; done

kubectl rolling-update kubia-v1 kubia-v2 --image=luksa/kubia:v2
# Command "rolling-update" is deprecated, use "rollout" instead
# Created kubia-v2
# Scaling up kubia-v2 from 0 to 3, scaling down kubia-v1 from 3 to 0 (keep 3 pods available, don't exceed 4 pods)
# Scaling kubia-v2 up to 1
# Scaling kubia-v1 down to 2
# Scaling kubia-v2 up to 2
# Scaling kubia-v1 down to 1
# Scaling kubia-v2 up to 3
# Scaling kubia-v1 down to 0
# Update succeeded. Deleting kubia-v1
# replicationcontroller/kubia-v2 rolling updated to "kubia-v2"

## new label added to pod template
##  - old and new will be different deployment label value
# kubectl describe rc kubia-v2
# Name:         kubia-v2
# Namespace:    default
# Selector:     app=kubia,deployment=51a729005e77c458297d81cb1da78b83
# Labels:       app=kubia
# ...
# Pod Template:
#   Labels:  app=kubia
#            deployment=51a729005e77c458297d81cb1da78b83

## rolling update performed by client (kubectl) rather than k8s master
## not good - eg) what if network disconnected?
##          - imperative rather than declarative
##          - image tag in original manifest won't be updated

#### deployment
## rs created by deployment add pod-template-hash label
## deployment creates multiple rs — one for each version of the pod template
## deploy.spec.strategy.type - RollingUpdate or Recreate
kubectl create -f inaction/ch09/kubia-deployment-v1.yaml --record

kubectl patch deployment kubia -p '{"spec": {"minReadySeconds": 10}}'

## ways of modifying deployment
kubectl set image deployment kubia nodejs=luksa/kubia:v2
kubectl patch deployment kubia -p '{"spec":{"template": {"spec": {"containers": [{"name":"nodejs", "image": "luksa/kubia:v2"}]}}}}'
# create or update
kubectl apply -f kubia-deployment-v2.yaml
# update only - should have existing resource
kubectl replace -f kubia-deployment-v2.yaml

# while true; do curl http://172.28.175.25:30000; sleep 1; done

## changes in config map doesn't update deployment
## better to create a different config map

## old rs kept - good for rollout
kubectl set image deployment kubia nodejs=luksa/kubia:v3

# kubectl rollout status deployment kubia

kubectl rollout undo deployment kubia

kubectl rollout history deployment kubia

kubectl rollout undo deployment kubia --to-revision=1

## revisionHistoryLimit - defaults to 10
# spec:
#   strategy:
#     rollingUpdate:
#       maxSurge: 1
#       maxUnavailable: 0
#   type: RollingUpdate

# maxSurge - % or #, max pods to # replicas during update, default 25%
# maxUnavailable - % or #, min pods to # replicas during update, default 25%

kubectl set image deployment kubia nodejs=luksa/kubia:v4

kubectl rollout pause deployment kubia
kubectl rollout resume deployment kubia