minikube start \
    --cpus 2 \
    --memory 4096 \
    --kubernetes-version v1.15.4 \
    --insecure-registry 10.0.0.0/24s

kubectl run kubia --image=luksa/kubia --port=8080 --generator=run/v1
