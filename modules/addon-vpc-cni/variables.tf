variable "eks_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_version" {
  description = "EKS cluster version"
  type        = string
}

variable "latest_addon_version" {
  description = "true to use latest addon version or false to use current verion"
  type        = bool
}

variable "resolve_conflicts_on_create" {
  description = "How to resolve field value conflicts when migrating a self-managed add-on to an Amazon EKS add-on. Valid values are NONE and OVERWRITE"
  type        = string
}

variable "resolve_conflicts_on_update" {
  description = "How to resolve field value conflicts for an Amazon EKS add-on if you've changed a value from the Amazon EKS default value. Valid values are NONE, OVERWRITE, and PRESERVE"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider arn from Control Plane"
  type        = string
}

variable "pod_subnet_ids" {
  description = "Pod networks ids"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security Group from Control Plane for all nodes"
  type        = string
}

variable "eniconfig_create" {
  description = "Create Eniconfig using kubernetes provider. Will fail if no access to controlplane"
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags."
  type        = map(string)
  default     = {}
}
