terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules/eks"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"

  mock_outputs = {
    vpc_id          = "vpc-00000000000000000"
    private_subnets = ["subnet-00000000000000001", "subnet-00000000000000002", "subnet-00000000000000003"]
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

locals {
  live_dir    = dirname(find_in_parent_folders("root.hcl"))
  cloud       = get_env("CLOUD", "ministack")
  root        = read_terragrunt_config(find_in_parent_folders("root.hcl")).locals
  profile     = read_terragrunt_config("${local.live_dir}/${local.cloud}.hcl").locals
  environment = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals

  name_prefix = "${local.root.project}-${local.environment.environment}"
}

inputs = {
  cluster_name       = "${local.name_prefix}-eks"
  kubernetes_version = local.profile.kubernetes_version
  is_local           = local.profile.is_local

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  node_instance_type = local.environment.node_type
  use_spot           = local.environment.use_spot
  node_min_size      = local.environment.node_min_size
  node_max_size      = local.environment.node_max_size
  node_desired_size  = local.environment.node_desired_size

  tags = merge(
    local.root.default_tags,
    {
      Environment = local.environment.environment
    }
  )
}
