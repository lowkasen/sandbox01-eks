1. Spin up infrastrcuture: template 01
2. Spin up eks cluster: template 02
3. Spin up eks addons: template 03

## ArgoCD commands

1. argocd admin initial-password -n argocd
2. kubectl port-forward svc/argocd-server 8080:443 -n argocd
