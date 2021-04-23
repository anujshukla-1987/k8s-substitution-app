# Fetching outputs

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "eks-terraform-anuj"
    key    = "vpc/vpc.tfstate"
    region = "eu-west-1"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "AmazonSSMWorkerNodePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

module alb-ingress-controller-policy {
  source = "../../terraform-modules/terraform-module-aws-iam-policy/"

  policy_name        = "alb-ingress-controller-policy"
  policy_description = "Policy for ALB Ingress Controller"
  policy_document    = file("${path.module}/policies/alb-ingress-controller-policy.json")
}

module kube2iam-policy {
  source = "../../terraform-modules/terraform-module-aws-iam-policy/"

  policy_name        = "kube2iam-policy"
  policy_description = "Policy for Kube2Iam"
  policy_document    = file("${path.module}/policies/kube2iam-policy.json")
}

module external-dns-policy {
  source = "../../terraform-modules/terraform-module-aws-iam-policy/"

  policy_name        = "external-dns-policy"
  policy_description = "Policy for External DNS controller"
  policy_document    = file("${path.module}/policies/external-dns-policy.json")
}

module cluster-autoscalar-policy {
  source = "../../terraform-modules/terraform-module-aws-iam-policy/"

  policy_name        = "cluster-autoscalar-policy"
  policy_description = "Policy for Cluster Autoscalar"
  policy_document    = file("${path.module}/policies/cluster-autoscalar-policy.json")
}

module eks_worker_role {
  source = "../../terraform-modules/terraform-module-aws-iam-role/"

  iam_role_name        = "eks_worker_role"
  iam_role_description = "Worker role for EKS node"
  assume_role_policy   = file("${path.module}/policies/assume-role-policy.json")
  iam_policy_arns = [module.alb-ingress-controller-policy.policy_arn,
    module.external-dns-policy.policy_arn,
    data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn,
    module.kube2iam-policy.policy_arn,
    data.aws_iam_policy.AmazonEKS_CNI_Policy.arn,
  data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn,
  data.aws_iam_policy.AmazonSSMWorkerNodePolicy.arn, module.cluster-autoscalar-policy.policy_arn]
}

resource "aws_iam_instance_profile" "eks_worker_instance_profile" {
  name = "eks_worker_instance_profile"
  role = module.eks_worker_role.iam_role_name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "13.1.0"


  cluster_name                = "demo-k8s-cluster"
  cluster_version             = "1.18"
  map_users                   = var.map_users
  map_roles                   = var.map_roles
  subnets                     = data.terraform_remote_state.vpc.outputs.private_subnets
  vpc_id                      = data.terraform_remote_state.vpc.outputs.vpc_id
  manage_worker_iam_resources = false

  worker_groups_launch_template = [
    {
      name                      = "spot-fleet-application-components"
      override_instance_types   = ["t3a.large", "t3.large"]
      spot_instance_pools       = 2
      asg_min_size              = 1
      asg_max_size              = 3
      asg_desired_capacity      = 1
      key_name                  = var.enable_ssh ? var.sshkey : null
      public_ip                 = false
      iam_instance_profile_name = aws_iam_instance_profile.eks_worker_instance_profile.name
      tags                      = local.asg_tags
      depends_on                = [aws_iam_instance_profile.eks_worker_instance_profile]
    }
  ]

}
