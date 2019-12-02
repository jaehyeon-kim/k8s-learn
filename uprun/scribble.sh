######## Ch5 Pods

kubectl apply -f uprun/ch05/kuard-pod-full.yaml

kubectl port-forward kuard 8080:8080

kubectl exec kuard -- ls -alt data

######## Ch6 Labels and Annotations

