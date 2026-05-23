locals {
  project = "finops-ministack"

  default_tags = {
    Project   = "ministack"
    ManagedBy = "Terragrunt"
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"

  contents = <<EOF
terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}
EOF
}
