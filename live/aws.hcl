locals {
  is_local           = false
  aws_region         = "eu-central-1"
  vpc_cidr           = "10.1.0.0/16"
  kubernetes_version = "1.33"
  azs                = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets     = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  tfstate_bucket = "finops-ministack-tfstate-eu-central-1"
  tfstate_lock   = "finops-ministack-lock-eu-central-1"
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = local.tfstate_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = local.tfstate_lock
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = ${jsonencode(read_terragrunt_config(find_in_parent_folders("root.hcl")).locals.default_tags)}
  }
}
EOF
}
