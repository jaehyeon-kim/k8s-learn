## Kubernetes Visualizer

[Kubernetes Operational View - read-only system dashboard for multiple K8s clusters](https://kubernetes-operational-view.readthedocs.io/)

```bash
#git clone  https://github.com/schoolofdevops/kube-ops-view
kubectl apply -f kube-ops-view/deploy/

# kubectl get svc
# NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
# kube-ops-view         NodePort    10.101.158.121   <none>        80:32000/TCP   100s
# kube-ops-view-redis   ClusterIP   10.110.148.14    <none>        6379/TCP       100s
# kubernetes            ClusterIP   10.96.0.1        <none>        443/TCP        5d17h

# if minikube
http://<minikube-ip>:32000/#scale=2.0

```

### Resources
* [Ultimate Kubernetes Bootcamp - Kubernetes Visualizer](https://schoolofdevops.github.io/ultimate-kubernetes-bootcamp/kube_visualizer/)