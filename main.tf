/**
 * # terraform-eks-full
 * ## Create EKS cluster with Controller, Managed Nodegroups and add-ons
 *
 * ### Steps to create for Controller:
 *  1. IAM Role
 *  2. KMS Key
 *  3. Security Group
 *  4. Logs stream in CloudWatch
 *  5. Control Plane
 *
 * ### Steps to create Nodegroups
 *  1. IAM Role
 *  2. Security Group
 *  3. Autoscale Launch Template
 *  4. EKS NodeGroup ASG from template
 *
 * ### Steps to create addons:
 * #### VPC-CNI
 *  1. IAM Role
 *  2. EBS CNI Driver
 * NB! VPC-CNI set to use custom VPC for pod networks. Eniconfig is needed.
 * ToDo: Add eniconfig by applying kubectl apply -f ENICONFIG.yaml
 * NB! Node system ASG refresh needed.
 *
 * #### EBS-CSI
 *  1. IAM Role
 *  2. EBS CSI Driver
 *  3. Add EBS SCI Driver ARN to default EBS KMS Key users
 *
 * #### CoreDNS
 *  1. coredns deployment
 *
 * #### Kube-proxy
 *  1. kube-proxy deployment
 *
 * #### Iam Roles for Service Accounts
 *  1. Create default IRSA if enabled: Autoscaler, ALB Controller, External Secrets Operator, Dashboard.
 *  2. Custom IRSA if set (available variables for template: "eks_name" and "account_id")
 *
 * #### Custom OIDC
 *  1. Create Additional custom OIDC provider if set.

 * ## ToDo: move all internal config to separate submodule
 * NB!!!Connection to control plane required!!!
 * provider "kubernetes" {
 *  config_path    = "~/.kube/config"
 *  config_context = module.controlplane.eks_arn
 *}
 * Create var.ebs_kms_key if == 0 get default from aws
 * in case != use it and add cluster balancer autoscaler to users of this key.
 * OR ad designated users to KMS key usage right after custom KMS key creation
 * COEXT-68712

 */
data "aws_region" "current" {}
data "aws_ebs_default_kms_key" "current" {}
data "aws_kms_key" "current" {
  key_id = data.aws_ebs_default_kms_key.current.key_arn
}

module "controlplane" {
  source = "./modules/controlplane"

  name                              = var.name
  eks_version                       = var.eks_version
  service_ipv4_cidr                 = var.service_ipv4_cidr
  control_plane_allowed_networks    = var.control_plane_allowed_networks
  log_retention_in_days             = try(var.log_retention_in_days, 30)
  current_region                    = data.aws_region.current.name
  controller_well_known_policy_arns = var.controller_well_known_policy_arns
  controller_custom_iam_policy      = var.controller_custom_iam_policy
  vpc_id                            = var.vpc_id
  private_subnet_ids                = var.private_subnet_ids

  tags = merge(
    var.tags,
    { Name = var.name }
  )
}

module "alb" {
  source = "./modules/alb"

  vpc_id                = var.vpc_id
  eks_name              = var.name
  alb_internal          = var.alb_internal
  subnet_ids            = var.private_subnet_ids
  certificate_arn       = var.alb_certificate_arn
  dns_zone_id           = var.dns_zone_id
  alb_delete_protection = length(module.controlplane.arn) > 0 ? true : false

  tags = merge(
    var.tags,
    var.tags_alb
  )
}

locals {
  create_nodes = length(var.nodegroups) == 0 ? 0 : 1
}

module "nodegroups" {
  source = "./modules/nodegroups"
  count  = local.create_nodes

  name                        = var.name
  eks_version                 = var.eks_version
  service_ipv4_cidr           = var.service_ipv4_cidr
  nodegroups                  = var.nodegroups
  key_name                    = var.key_name
  subnet_ids                  = var.private_subnet_ids
  vpc_id                      = var.vpc_id
  node_well_known_policy_arns = var.node_well_known_policy_arns
  eks_security_group_id       = module.controlplane.security_group_id
  alb_security_group_id       = module.alb.alb_sg_id
  eks_endpoint                = module.controlplane.endpoint
  eks_ca_cert                 = module.controlplane.ca_cert
  kms_ebs_key_id              = var.kms_ebs_key_id == null ? data.aws_kms_key.current.arn : var.kms_ebs_key_id

  tags = merge(
    var.tags,
    var.tags_nodegroup
  )

  depends_on = [
    module.controlplane,
    #    module.alb
  ]

}

module "addon_vpc_cni" {
  source = "./modules/addon-vpc-cni"

  eks_name                    = var.name
  eks_version                 = module.controlplane.version
  latest_addon_version        = var.latest_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  pod_subnet_ids              = var.pod_subnet_ids
  eks_security_group_id       = module.controlplane.security_group_id
  oidc_provider_arn           = module.controlplane.oidc_provider.arn
  eniconfig_create            = try(var.eniconfig_create, false)

  tags = try(var.tags, {})

  depends_on = [
    module.nodegroups
  ]
}

module "addon_ebs_csi" {
  source                      = "./modules/addon-ebs-csi"
  count                       = local.create_nodes
  eks_name                    = var.name
  eks_version                 = module.controlplane.version
  latest_addon_version        = var.latest_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  oidc_provider_arn           = module.controlplane.oidc_provider.arn

  tags = var.tags

  depends_on = [
    module.nodegroups,
    module.addon_vpc_cni
  ]
}

module "addon_efs_csi" {
  source                      = "./modules/addon-efs-csi"
  count                       = local.create_nodes
  eks_name                    = var.name
  eks_version                 = module.controlplane.version
  latest_addon_version        = var.latest_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  oidc_provider_arn           = module.controlplane.oidc_provider.arn

  tags = var.tags

  depends_on = [
    module.nodegroups,
    module.addon_vpc_cni
  ]
}

module "addon_coredns" {
  source                      = "./modules/addon-coredns"
  count                       = local.create_nodes
  eks_name                    = var.name
  eks_version                 = module.controlplane.version
  latest_addon_version        = var.latest_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags

  depends_on = [
    module.nodegroups,
    module.addon_vpc_cni
  ]
}

module "addon_kube_proxy" {
  source                      = "./modules/addon-kube-proxy"
  count                       = local.create_nodes
  eks_name                    = var.name
  eks_version                 = module.controlplane.version
  latest_addon_version        = var.latest_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags

  depends_on = [
    module.nodegroups,
    module.addon_vpc_cni
  ]
}


module "irsa" {
  source = "./modules/irsa"

  eks_name                   = var.name
  oidc_provider_arn          = module.controlplane.oidc_provider.arn
  irsa_create_autoscaler     = var.irsa_create_autoscaler
  irsa_create_alb_controller = var.irsa_create_alb_controller
  irsa_create_eso            = var.irsa_create_eso
  irsa_create_gen_dashboard  = var.irsa_create_gen_dashboard
  irsa_custom                = var.irsa_custom

  tags = merge(
    var.tags,
    var.tags_irsa
  )
}

module "extra_oidc" {
  source = "./modules/oidc"

  for_each = length(var.oidc_config) == 0 ? {} : var.oidc_config

  eks_name    = var.name
  oidc_config = var.oidc_config

  tags = merge(
    var.tags,
    var.tags_oidc
  )
}
