locals {
  environment       = "prod"
  single_nat        = false
  use_spot          = false
  node_type         = "m5.large"
  node_min_size     = 2
  node_max_size     = 5
  node_desired_size = 3
}
