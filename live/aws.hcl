locals {
  # Environment Configuration
  is_local = false

  # Region and Availability Zones
  aws_region = "eu-central-1"
   azs        = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]

  # VPC Configuration
  vpc_cidr        = "10.0.0.0/16"
  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
  public_subnets  = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]

  # EKS Configuration
  kubernetes_version = "1.33"

  # State Management
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
