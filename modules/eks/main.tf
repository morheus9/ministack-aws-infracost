locals {
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  managed_node_groups = var.is_local ? {} : {
    main = {
      instance_types = [var.node_instance_type]
      capacity_type  = var.use_spot ? "SPOT" : "ON_DEMAND"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.20"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  enable_irsa             = !var.is_local
  create_kms_key          = !var.is_local
  cluster_addons          = var.is_local ? {} : local.cluster_addons
  eks_managed_node_groups = local.managed_node_groups

  tags = var.tags
}
