provider "aws" {
  region = "ap-southeast-1"
  # shared_config_files      = ["./.aws/config"]
  # shared_credentials_files = ["./.aws/credentials"]
  # profile                  = "sandbox01"
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

provider "kubectl" {
  apply_retry_count      = 10
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
  }
}
