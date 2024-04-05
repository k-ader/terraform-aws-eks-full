variable "eks_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider arn from Control Plane"
  type        = string
}

variable "irsa_create_autoscaler" {
  description = "Create IRSA for Cluster Autoscaler"
  type        = bool
}

variable "irsa_create_alb_controller" {
  description = "Create IRSA for ALB controllerr"
  type        = bool
}

variable "irsa_create_eso" {
  description = "Create IRSA for External Secrets Operator"
  type        = bool
}

variable "irsa_create_gen_dashboard" {
  description = "Create IRSA for Cluster Autoscaler"
  type        = bool
}

variable "irsa_custom" {
  description = <<EOF
    Custom IRSA.
    object with next values:
      path = path for policy, default = "/"
      policy_file = json template (optional). with variables "eks_name" and "account_id", can be empty if AWS managed policy set
      managed_policy_arn = ARN (optional) , can be empty if policy_file set
      service_account = name of service account for IAM authentication
      namespace = namespace where ServiceAccount will be created
  EOF
  type        = any
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags."
  type        = map(string)
  default     = {}
}
