resource "aws_eks_identity_provider_config" "oidc" {

  cluster_name = var.eks_name

  oidc {
    client_id                     = try(var.oidc_config.client_id, null)
    issuer_url                    = try(var.oidc_config.issuer_url, null)
    identity_provider_config_name = try(var.oidc_config.identity_provider_config_name, null)
    groups_claim                  = try(var.oidc_config.groups_claim, null)
    groups_prefix                 = try(var.oidc_config.groups_prefix, null)
    username_claim                = try(var.oidc_config.username_claim, null)
    username_prefix               = try(var.oidc_config.username_prefix, null)
    required_claims               = try(var.oidc_config.required_claims, null)
  }

  tags = var.tags
}
