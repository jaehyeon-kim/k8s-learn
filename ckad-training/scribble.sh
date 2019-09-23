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