variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes control plane version."
  type        = string
  default     = "1.33"
}

variable "vpc_id" {
  description = "VPC ID for the cluster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the control plane and nodes."
  type        = list(string)
}

variable "is_local" {
  description = "Ministack/local emulator profile with reduced AWS integrations."
  type        = bool
  default     = false
}

variable "node_instance_type" {
  description = "Managed node group instance type."
  type        = string
  default     = "t3.medium"
}

variable "use_spot" {
  description = "Use SPOT capacity for managed node groups."
  type        = bool
  default     = false
}

variable "node_min_size" {
  description = "Minimum node group size."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum node group size."
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Desired node group size."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags applied to EKS resources."
  type        = map(string)
  default     = {}
}
