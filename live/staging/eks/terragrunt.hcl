include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "profile" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/${get_env("CLOUD", "ministack")}.hcl"
}

include "eks" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/eks.hcl"
}

dependencies {
  paths = ["../vpc"]
}
