######
###### 02-core-concepts
######
kubectl run hello-minikube
kubectl cluster-info
kubectl get nodes

kubectl run nginx --image nginx
kubectl get pods


kubectl create -f pod-definition.yml
kubectl get pods
kubectl describe pod myapp-pod
kubectl delete pod myapp-pod
---
apiVersion: v1
kind: Pod
metadata:
    name: myapp-pod
    labels:
        app: myapp
        type: front-end
spec:
    containers:
        - name: nginx-container
          image: nginx
---

kind: apiVersion
POD: v1
Service: v1
ReplicaSet: apps/v1
Deployment: apps/v1

kubectl create -f 02-core-concepts/pod-definition.yml
# pod/myapp-pod created

# edit an existing pod if yaml is not there
kubectl get pod myapp-pod -o yaml > pod-definition.yaml
kubectl edit pod <pod-name>

# replication controller
kubectl create -f 02-core-concepts/rc-definition.yml 
replicationcontroller/myapp-rc created

kubectl delete replicationcontroller myapp-rc


kubectl create -f 02-core-concepts/replicaset.definition.yml 
replicaset.apps/myapp-replicaset created

kubectl get replicasets
kubectl delete replicaset myapp-replicaset

## update replicaset
# 1. after eg) change replacas: 6
kubectl replace -f 02-core-concepts/replicaset.definition.yml 
# 2. use kubectl
kubectl scale --replicas=6 -f 02-core-concepts/replicaset.definition.yml
# or
kubectl scale --replicas=6 replicaset myapp-replicaset

## deployment
kubectl create -f 02-core-concepts/deployment-definition.yml 
# deployment.apps/myapp-deployment created

kubectl get deployments
kubectl get replicasets # replicaset created automatically

# get all objects
kubectl get all




#### TIPS
## https://kubernetes.io/docs/reference/kubectl/conventions/
## Create an NGINX Pod
kubectl run --generator=run-pod/v1 nginx --image=nginx

## Generate POD Manifest YAML file (-o yaml). Don't create it(--dry-run)
kubectl run --generator=run-pod/v1 nginx --image=nginx --dry-run -o yaml

## Create a deployment
kubectl run --generator=deployment/v1beta1 nginx --image=nginx
# Or the newer recommended way:
kubectl create deployment --image=nginx nginx

## Generate Deployment YAML file (-o yaml). Don't create it(--dry-run)
kubectl run --generator=deployment/v1beta1 nginx --image=nginx --dry-run -o yaml
# Or
kubectl create deployment --image=nginx nginx --dry-run -o yaml

## Generate Deployment YAML file (-o yaml). Don't create it(--dry-run) with 4 Replicas (--replicas=4)
kubectl run --generator=deployment/v1beta1 nginx --image=nginx --dry-run --replicas=4 -o yaml
# kubectl create deployment does not have a --replicas option. 
# You could first create it and then scale it using the kubectl scale command.

## Save it to a file - (If you need to modify or add some other details)
kubectl run --generator=deployment/v1beta1 nginx --image=nginx --dry-run --replicas=4 -o yaml > nginx-deployment.yaml

## Create a Service named nginx of type NodePort and expose it on port 30080 on the nodes:
kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run -o yaml

## namespaces - kube-system, Default, kube-public, dev, prod ...
# different policies
# resource limits
# DNS
# eg) mysql.connect('db-service'), mysql.connect('db-service.dev.svc.cluster.local')
# db-service: service name
# dev: namespace
# svc: service
# cluster.local: domain

kubectl get pods --namespace=kube-system
kubectl create -f <definition-file> --namespace mynamespace

kubectl create -f 02-core-concepts/namespace-dev.yml
# or
kubernetes create namespace dev

kubectl create namespace dev --dry-run -o yaml
# apiVersion: v1
# kind: Namespace
# metadata:
#   creationTimestamp: null
#   name: dev
# spec: {}
# status: {}

# get current context
kubectl config current-context
# minikube

# switch namespace
kubectl config set-context $(kubectl config current-context) --namespace=dev
# Context "minikube" modified.

kubectl get pods --all-namespaces

kubectl create -f 02-core-concepts/compute-quota.yml

######
###### 03-configuration
######

# ---
# FROM Ubuntu
# ENTRYPOINT ["sleep"]
# CMD["5"]
# ---
## command appended to entrypoint
# docker run mycontainer # --> sleep 5
# docker run mycontainer 10 # --> sleep 10 
# docker run --entrypoint sleepup mycontainer --> sleepup 5

# docker run --name ubuntu-sleeper ubuntu-sleeper
apiVersion: v1
kind: Pod
metadata:
    name: ubuntu-sleeper-pod
spec:
    containers:
        - name: ubuntu-sleeper
          image: ubutu-sleeper
          command: ["sleepup"] # --> ENTRYPOINT
          args: ["10"] # --> CMD

## Edit a POD
# Remember, you CANNOT edit specifications of an existing POD other than the below.
# * spec.containers[*].image
# * spec.initContainers[*].image
# * spec.activeDeadlineSeconds
# * spec.tolerations

# kubectl edit pod myapp-pod
# need to recreate with a new/updated definition file

kubectl get pod myapp-pod -o yaml > new-myapp-pod.yaml
kubectl delete pod myapp-pod
kubectl create -f new-myapp-pod.yaml

## Edit Deployments
# With Deployments you can easily edit any field/property of the POD template. 
# Since the pod template is a child of the deployment specification, 
# with every change the deployment will automatically delete and create a new pod with the new changes. 
# So if you are asked to edit a property of a POD part of a deployment you may do that simply by running the command

kubectl edit deployment myapp-deployment

## Environment Variables
---
spec:
    containers:
        - name: ubuntu-sleeper
          image: ubutu-sleeper
          env:
            - name: APP_COLOR
              value: blue
---

## ConfigMap

kubectl create configmap <config-name> --from-literal=<key>=<value>
# kubectl create configmap app-config --from-literal=APP_COLOR=blue
kubectl create configmap <config-name> --from-file=<path-to-file>
# kubectl create configmap app-config --from-file=app_config.APP_COLOR

kubectl create -f 03-configuration/config-map.yml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_COLOR: blue
  APP_MODE: prod
---
---
spec:
    containers:
        - name: ubuntu-sleeper
          image: ubutu-sleeper
          envFrom:
            - configMapRef: app-config
          # or
          env:
            - name: APP_COLOR
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: APP_COLOR
          # or
          volumes:
            - name: app-config-volume
              configMap:
                name: app-config
---

## Secrets
kubectl create secret generic <secret-name> --from-literal=<key>=<value>
kubectl create secret generic <secret-name> --from-file=<path-to-file>

kubectl create -f 03-configuration/secret-data.yml
# base64 encode first into values
# echo -n 'mysql' | base64
# bXlzcWw=

# decode
# echo -n 'bXlzcWw=' | base64 --decode
# mysql

---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
data:
  DB_Host: bXlzcWw=
  DB_User: cm9vdA==
  DB_Password: cGFzd3Jk
---
---
spec:
    containers:
        - name: ubuntu-sleeper
          image: ubutu-sleeper
          envFrom:
            - secretRef: app-secret
          # or
          env:
            - name: DB_Password
              valueFrom:
                secretKeyRef:
                  name: app-secret
                  key: DB_Password
          # or
          volumes:
            - name: app-secret-volume
              secret:
                name: app-secret
---

# if volume
ls /opt/app-secret-volume
# DB_Host   DB_User   DB_Password
cat /opt/app-secret-volume/DB_Password
# paswrd

# Secrets are not encrypted, so it is not safer in that sense. However, some best practices around using secrets make it safer. As in best practices like:
# 1. Not checking-in secret object definition files to source code repositories.
# 2. Enabling Encryption at Rest for Secrets so they are stored encrypted in ETCD.
#   https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

# There are other better ways of handling sensitive data like passwords in Kubernetes, 
# such as using tools like Helm Secrets, HashiCorp Vault.


## Docker Security
# process isolation - docker runs in a namespace and can only see processes in its own namespace
# container runs as root if not specified eg) docker run --user=1000 ubuntu sleep 3600
#     can also defined in image (eg in Dockerfile)
# root user in container is not root user of host
#   root user in container has limited capabilities
#   note: docker run --cap-add MAC_ADMIN ... | docker run --cap-drop KILL ... | docker run --previledged ...

## Security Contexts
# security context can be set in pod level or container level - container level get priority

apiVersion: v1
kind: Pod
metadata:
  name: web-pod
spec:
  securityContext:
    runAsUser: 1000
    capabilities:
      add: ["MAC_ADMIN"]
  containers:
    - name: ubuntu
      image: ubuntu
      securityContext:
        runAsUser: 1000
        capabilities:
          add: ["MAC_ADMIN"]

## Service Accounts
# CKAD - Understand ServiceAccounts
# CKA
#   - Know how to configure authentication/authorization
#   - Understand Kubernetes security primitives

# 2 types of accounts
# User - Admin, Developer ...
# Service - monitoring app for performance metrics, Jenkins ...

kubectl create serviceaccount dashboard-sa

kubectl get serviceaccounts
kubectl describe serviceaccount dashboard-sa
# Name:                dashboard-sa
# Namespace:           default
# Labels:              <none>
# Annotations:         <none>
# Image pull secrets:  <none>
# Mountable secrets:   dashboard-sa-token-5pmtb
# Tokens:              dashboard-sa-token-5pmtb
# Events:              <none>

kubectl describe secret dashboard-sa-token-5pmtb
# Name:         dashboard-sa-token-5pmtb
# Namespace:    default
# Labels:       <none>
# Annotations:  kubernetes.io/service-account.name: dashboard-sa
#               kubernetes.io/service-account.uid: 9488cef2-0ac1-4cb3-8bfc-f76498b9ba1a

# Type:  kubernetes.io/service-account-token

# Data
# ====
# ca.crt:     1066 bytes
# namespace:  7 bytes
# token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.....

export token=eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.....
curl https://192.168.99.100:8443/api --insecure --header "Authorization: Bearer $token"
# {
#   "kind": "APIVersions",
#   "versions": [
#     "v1"
#   ],
#   "serverAddressByClientCIDRs": [
#     {
#       "clientCIDR": "0.0.0.0/0",
#       "serverAddress": "192.168.99.100:8443"
#     }
#   ]
# }

# create a service account -> implement RABC -> access kube-api
# if created inside Kubernetes cluster, secret can simply be mounted
# each namespace can have own service account with same name - eg) default

---
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  containers:
    - name: nginx-container
      image: nginx
      # automountServiceAccountToken: false
      # serviceAccount: dashboard-sa
      # If Pod, has to recreate for new serviceaccount
      # If Deployment, automatic roll over

---

kubectl create -f 03-configuration/pod-definition.yml 
kubectl descript pod myapp-pod

Name:         myapp-pod
Namespace:    default
Priority:     0
Node:         minikube/10.0.2.15
...
Containers:
  nginx-container:
    Container ID:   docker://7ed1684d1cc69e69b530107d00046f7a59eea00fa342eb2f1d49c9d041b82529
    Image:          nginx
    ...
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-lxvcv (ro)
Volumes:
  default-token-lxvcv:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-lxvcv
    Optional:    false

kubectl exec -it myapp-pod ls /var/run/secrets/kubernetes.io/serviceaccount
# ca.crt	namespace  token

kubectl exec -it myapp-pod cat /var/run/secrets/kubernetes.io/serviceaccount/token

## Resource Requirements
# CPU, MEM, Disk - if not avaialble, scheduler pending deployments

# CPU
#   eg 0.1 or "100m", min - "1m"
#   1 - 1 AWS vCPU, 1GCP Core, 1 Azure Core, 1 Hyperthread
#   CPU is throttled to limit
# MEM
#   "266Mi, "1Gi" - ending with "i" for exact bytes
#   MEM can consume more than limit but will terminate
