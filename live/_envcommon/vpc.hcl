terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v3.19.0"
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
  name = "${local.name_prefix}-vpc"
  cidr = local.profile.vpc_cidr

  azs             = local.profile.azs
  private_subnets = local.profile.private_subnets
  public_subnets  = local.profile.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = local.environment.single_nat
  one_nat_gateway_per_az = !local.environment.single_nat

  tags = merge(
    local.root.default_tags,
    {
      Environment = local.environment.environment
    }
  )
}
