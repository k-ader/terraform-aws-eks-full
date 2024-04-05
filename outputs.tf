output "kubectl_config_cmd" {
  description = "kubectl config command"
  value       = module.controlplane.kubeconfig_update_cmd
}

output "control_plane" {
  description = "Control Plane parameters"
  value = {
    "eks_name"     = try(module.controlplane.name, "")
    "eks_version"  = try(module.controlplane.version, "")
    "eks_arn"      = try(module.controlplane.arn, "")
    "eks_endpoint" = try(module.controlplane.endpoint, "")
    "eks_oidc_arn" = try(module.controlplane.oidc_provider.arn, "")
    "eks_oidc_url" = try(module.controlplane.oidc_provider.url, "")

  }
}

output "nodegroup" {
  description = "Node Groups parameters and template versions"
  value       = try(module.nodegroups.nodegroup_template_version, "")
}
#
output "addon_vpc_cni" {
  description = "VPC CNI add-on parameters"
  value = {
    "arn"     = try(module.addon_vpc_cni.arn, "")
    "version" = try(module.addon_vpc_cni.version, "")
  }
}

output "addon_ebs_csi" {
  description = "EBS CSI add-on parameters"
  value = {
    "arn"      = try(module.addon_ebs_csi.arn, "")
    "version"  = try(module.addon_ebs_csi.version, "")
    "role_arn" = try(module.addon_ebs_csi.iam_role_arn, "")
  }
}

output "addon_efs_csi" {
  description = "EFS CSI add-on parameters"
  value = {
    "arn"      = try(module.addon_efs_csi.arn, "")
    "version"  = try(module.addon_efs_csi.version, "")
    "role_arn" = try(module.addon_efs_csi.role_arn, "")
  }
}

output "addon_coredns" {
  description = "Core DNS add-on parameters"
  value = {
    "arn"     = try(module.addon_coredns.arn, "")
    "version" = try(module.addon_coredns.version, "")
  }
}

output "addon_kube_proxy" {
  description = "Kube proxy add-on parameters"
  value = {
    "arn"     = try(module.addon_kube_proxy.arn, "")
    "version" = try(module.addon_kube_proxy.version, "")
  }
}

output "eniconfig" {
  description = "ENIconfig for kubectl apply parameters. Custom netwirking for pods"
  value       = try(module.addon_vpc_cni.eniconfig_manifest, "")
}

output "irsa" {
  description = "IAM Roles for Service Accounts"
  value       = try(module.irsa.irsa, "")
}
