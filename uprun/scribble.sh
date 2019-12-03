######## Ch5 Pods
kubectl run kuard --generator=run-pod/v1 \
    --image=gcr.io/kuar-demo/kuard-amd64:blue

kubectl apply -f uprun/ch05/kuard-pod-full.yaml

kubectl port-forward kuard 8080:8080

kubectl exec kuard -- ls -alt data

######## Ch6 Labels and Annotations

#### labels
kubectl run alpaca-prod --image=gcr.io/kuar-demo/kuard-amd64:blue \
    --replicas=2 --labels='ver=1,app=alpaca,env=prod'

kubectl run alpaca-test --image=gcr.io/kuar-demo/kuard-amd64:green \
    --replicas=1 --labels='ver=2,app=alpaca,env=test'

kubectl run bandicoot-prod --image=gcr.io/kuar-demo/kuard-amd64:green \
    --replicas=2 --labels='ver=2,app=bandicoot,env=prod'

kubectl run bandicoot-staging --image=gcr.io/kuar-demo/kuard-amd64:green \
    --replicas=1 --labels='ver=2,app=bandicoot,env=staging'

# only affects deploy, not rs or po
kubectl label deploy alpaca-test 'canary=true'
kubectl get deploy -L canary
kubectl label deploy alpaca-test 'canary-'

# labels can be used by selector
kubectl get po --selector='ver=2'
kubectl get po --selector='app=bandicoot,ver=2'
kubectl get po --selector='app in (alpaca,bandicoot)'

kubectl get deploy --selector='!canary'
# use ' instead of "
# -bash: !canary: event not found

# key=value -- key!=value
# key in (value1,value2) -- key notin (value1,value2)
# key -- !key

kubectl get po -l 'ver=2,!canary'

# app=alpaca,ver in (1,2)
# for deploy/rs/po ...
# selector:
#   matchLabels:
#     app: alpaca
#   matchExpressions:
#     - {key: ver, operator: In, values: [1,2]}

# app=alpaca,ver=1
# for svc and rc
# selector:
#   app: alpaca
#   ver: 1

#### annotations
# metadata:
#   annotations:
#     example.com/icon-url: "https://example.com/icon.png"
