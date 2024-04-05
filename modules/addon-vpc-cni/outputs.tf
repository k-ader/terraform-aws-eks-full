output "iam_role" {
  description = "IAM Role for VPC CNI add-on arn"
  value       = aws_iam_role.vpc_cni_addon.arn
}

output "arn" {
  description = "VPC CNI add-on arn"
  value       = aws_eks_addon.vpc_cni.arn
}

output "version" {
  description = "VPC CNI add-on version"
  value       = aws_eks_addon.vpc_cni.addon_version
}

output "eniconfig_manifest" {
  description = "ENIconfig for kubectl apply parameters. Custom netwirking for pods"
  value       = local.manifest
}
