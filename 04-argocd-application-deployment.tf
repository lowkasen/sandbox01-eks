resource "kubectl_manifest" "apps-ns" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: apps
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
YAML
}

# resource "kubectl_manifest" "helm-guestbook" {
#   depends_on = [kubectl_manifest.app-helm-guestbook-ns]
#   yaml_body  = <<YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: helm-guestbook
#   namespace: argocd
#   finalizers:
#     # The default behaviour is foreground cascading deletion
#     - resources-finalizer.argocd.argoproj.io
#     # Alternatively, you can use background cascading deletion
#     # - resources-finalizer.argocd.argoproj.io/background
# spec:
#   project: default
#   source:
#     repoURL: https://github.com/lowkasen/sandbox01-eks
#     path: apps/helm-guestbook
#   destination:
#     server: "https://kubernetes.default.svc"
#     namespace: app-helm-guestbook
#   syncPolicy:
#     automated:
#       prune: false
#       selfHeal: false
# YAML
# }

resource "kubectl_manifest" "app-of-apps" {
  depends_on = [kubectl_manifest.apps-ns]
  yaml_body  = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
  finalizers:
    # The default behaviour is foreground cascading deletion
    - resources-finalizer.argocd.argoproj.io
    # Alternatively, you can use background cascading deletion
    # - resources-finalizer.argocd.argoproj.io/background
spec:
  project: default
  source:
    repoURL: https://github.com/lowkasen/sandbox01-eks
    path: app-of-apps
  destination:
    server: "https://kubernetes.default.svc"
    namespace: apps
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
YAML
}
