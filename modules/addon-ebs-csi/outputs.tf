output "iam_role_arn" {
  description = "IAM Role for EBS CSI add-on arn"
  value       = aws_iam_role.ebs_csi.arn
}

output "arn" {
  description = "EBS CSI add-on arn"
  value       = aws_eks_addon.aws_ebs_csi_driver.arn
}

output "version" {
  description = "EBS CSI add-on version"
  value       = aws_eks_addon.aws_ebs_csi_driver.addon_version
}
