minikube start --memory .. --cpu

kubectl apply -f devenv/kube-ops-view/deploy/

# if minikube
http://<minikube-ip>:32000/#scale=2.0

watch -n 1 kubectl get pods,deploy,rs,svc

minikube dashboard

kubectl apply -f pods/vote-pod.yml

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
kubectl apply -f pods/db-pod.yml
# check if directory exists in host and mounted in pod

kubectl apply -f pods/multi_container_pod.yml

kubectl exec -it web sh # default nginx
kubectl exec -it web sh -c sync

kubectl logs web -c nginx
kubectl logs web -c sync