variable "eks_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_config" {
  description = "(Required) Nested attribute containing OpenID Connect identity provider information for the cluster."
  type = object({
    client_id                     = string
    issuer_url                    = string
    identity_provider_config_name = string
    groups_claim                  = string
    groups_prefix                 = optional(string)
    username_claim                = string
    username_prefix               = optional(string)
    required_claims               = optional(map(string))
  })
  default = {
    client_id                     = null
    issuer_url                    = null
    identity_provider_config_name = null
    groups_claim                  = null
    groups_prefix                 = null
    username_claim                = null
    username_prefix               = null
    required_claims               = {}
  }
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags."
  type        = map(string)
  default     = {}
}
