module "aws_eks" {
  source = "../"

  eks_version = "1.27"
  name        = "myeks01"

  vpc_id                         = var.vpc_id
  control_plane_allowed_networks = var.local_networks
  key_name                       = var.ssh_key_name
  kms_ebs_key_id                 = var.kms_key_id
  log_retention_in_days          = 30 # for dev,test,stage = 30
  pod_subnet_ids                 = var.pod_subnet_ids
  private_subnet_ids             = var.private_subnet_ids
  alb_certificate_arn            = var.certificate_arn
  dns_zone_id                    = var.route53_zone_id

  oidc_config = var.eks.oidc_config

  irsa_create_autoscaler     = var.eks.irsa.irsa_create_autoscaler
  irsa_create_alb_controller = var.eks.irsa.irsa_create_alb_controller
  irsa_create_eso            = var.eks.irsa.irsa_create_eso
  irsa_custom = { for key, value in var.eks.irsa.irsa_custom :
    key => merge(
      value,
      {
        policy_file = try("${path.cwd}/${lookup(value, "policy_file", null)}", null)
      }
    )
  }

  tags = merge(
    var.tags
  )

}
