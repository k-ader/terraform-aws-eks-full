variable "name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_version" {
  description = "Desired Kubernetes master version"
  type        = string
}

variable "service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes pod and service IP addresses from."
  type        = string
}

variable "current_region" {
  description = "Current working region"
  type        = string
}

variable "vpc_id" {
  description = "vpc id for EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet id's where should located EKS cluster"
  type        = list(string)
}

variable "control_plane_allowed_networks" {
  description = "Subnets that allowed access to manage EKS cluster"
  type        = list(string)
}

variable "log_retention_in_days" {
  type        = number
  description = "How many days keep logs for controlplane"
  default     = 30
}

variable "controller_well_known_policy_arns" {
  description = "Default EKS cluster policies"
  type        = list(string)
}

variable "controller_custom_iam_policy" {
  description = "Custom policies for EKS controller "
  type        = map(string)
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags."
  type        = map(string)
  default     = {}
}
