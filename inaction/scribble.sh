watch -n 1 kubectl get po,rc,svc -o wide --show-labels

###### ch02
kubectl run kubia --image=luksa/kubia --port=8080 --generator=run/v1

kubectl get po

# minikube doesn't support LoadBalancer, use NodePort instead
kubectl expose rc kubia --type=LoadBalancer --name kubia-http
kubectl expose rc kubia --type=NodePort --name kubia-http

kubectl get svc

kubectl scale rc kubia --replicas=3

###### ch03
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
# more info than labels, not no something like labelSelector
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