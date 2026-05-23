locals {
  environment       = "staging"
  single_nat        = true
  use_spot          = true
  node_type         = "t3.medium"
  node_min_size     = 1
  node_max_size     = 3
  node_desired_size = 2
}
