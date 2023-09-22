locals {
  cluster_name    = "sandbox-01-eks-cluster"
  node_group_name = "sandbox-01-eks-cluster-ng"

  tags = {
    Blueprint  = local.cluster_name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

data "aws_eks_cluster" "default" {
  name = "sandbox-01-eks-cluster"
}

data "aws_eks_cluster_auth" "default" {
  name = "sandbox-01-eks-cluster"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}

# provider "kubectl" {
#   apply_retry_count      = 10
#   host                   = data.aws_eks_cluster.default.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
#   load_config_file       = false

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
#   }
# }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 19.15.2"

  cluster_name                   = local.cluster_name
  cluster_version                = 1.27
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # we uses only 1 security group to allow connection with Fargate, MNG, and Karpenter nodes
  create_cluster_security_group = false
  create_node_security_group    = false

  # eks_managed_node_groups = {
  #   initial = {
  #     node_group_name = local.node_group_name
  #     instance_types  = ["m5.large"]

  #     min_size     = 1
  #     max_size     = 5
  #     desired_size = 3
  #     subnet_ids   = module.vpc.private_subnets
  #   }
  # }

  fargate_profiles = {
    app_wildcard = {
      selectors = [
        { namespace = "app-*" }
      ]
    }
    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    }
    kube_system = {
      name = "kube-system"
      selectors = [
        { namespace = "kube-system" }
      ]
    }
    argocd = {
      name = "argocd"
      selectors = [
        { namespace = "argocd" }
      ]
    }
  }

  create_aws_auth_configmap = false
  manage_aws_auth_configmap = true
  aws_auth_roles = flatten([
    # var.eks_blueprints_platform_teams_aws_auth_configmap_role,
    # var.eks_blueprints_dev_teams_aws_auth_configmap_roles,
    #{
    #  rolearn  = module.karpenter.role_arn
    #  username = "system:node:{{EC2PrivateDNSName}}"
    #  groups = [
    #    "system:bootstrappers",
    #    "system:nodes",
    #  ]
    #},
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Admin" # The ARN of the IAM role
      username = "ops-role"                                                               # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"]                                                       # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ])

  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = "${local.environment}-karpenter"
  })
}
