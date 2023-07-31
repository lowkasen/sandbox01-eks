module "eks_blueprints_addons" {
  # Users should pin the version to the latest available release
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"

  eks_cluster_id        = module.eks.cluster_name
  eks_cluster_endpoint  = module.eks.cluster_endpoint
  eks_cluster_version   = module.eks.cluster_version
  eks_oidc_provider     = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn

  enable_argocd = true
  # This example shows how to set default ArgoCD Admin Password using SecretsManager with Helm Chart set_sensitive values.
  #   argocd_helm_config = {
  #     set_sensitive = [
  #       {
  #         name  = "configs.secret.argocdServerAdminPassword"
  #         value = bcrypt_hash.argo.id
  #       }
  #     ]
  #   }

  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying add-ons
  argocd_applications = {
    addons = {
      path               = "chart"
      repo_url           = "https://github.com/aws-samples/eks-blueprints-add-ons.git"
      add_on_application = true
    }
    # workloads = {
    #   path               = "helm-guestbook"
    #   repo_url           = "https://github.com/argoproj/argocd-example-apps.git"
    #   add_on_application = false
    # }
  }

  # Add-ons
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_load_balancer_controller  = true
  enable_cert_manager                  = true
  enable_karpenter                     = true
  enable_metrics_server                = true
  enable_argo_rollouts                 = true

  #   tags = local.tags
}
