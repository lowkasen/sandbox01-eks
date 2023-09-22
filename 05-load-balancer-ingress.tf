# resource "kubectl_manifest" "eks-alb" {
#   depends_on = [kubectl_manifest.apps-ns]
#   yaml_body  = <<YAML
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: eks-alb
#   annotations:
#     alb.ingress.kubernetes.io/scheme: internet-facing
#     alb.ingress.kubernetes.io/target-type: ip
# spec:
#   ingressClassName: alb
#   rules:
#     - http:
#         paths:
#           - path: /
#             pathType: Prefix
#             backend:
#               service:
#                 name: helm-guestbook
#                 port:
#                   number: 80
# YAML
# }
