locals {
  is_local           = true
  aws_region         = "us-east-1"
  vpc_cidr           = "10.0.0.0/16"
  kubernetes_version = "1.33"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  aws_endpoint   = get_env("MINISTACK_ENDPOINT", "http://localhost:4566")
  tfstate_bucket = "finops-ministack-tfstate"
  tfstate_lock   = "finops-ministack-lock"
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

    endpoint                    = local.aws_endpoint
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    access_key                  = "test"
    secret_key                  = "test"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  region                      = "${local.aws_region}"
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    autoscaling    = "${local.aws_endpoint}"
    cloudformation = "${local.aws_endpoint}"
    dynamodb       = "${local.aws_endpoint}"
    ec2            = "${local.aws_endpoint}"
    eks            = "${local.aws_endpoint}"
    iam            = "${local.aws_endpoint}"
    kms            = "${local.aws_endpoint}"
    logs           = "${local.aws_endpoint}"
    s3             = "${local.aws_endpoint}"
    sts            = "${local.aws_endpoint}"
  }

  default_tags {
    tags = ${jsonencode(read_terragrunt_config("${get_terragrunt_dir()}/root.hcl").locals.default_tags)}
  }
}
EOF
}
