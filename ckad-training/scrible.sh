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
