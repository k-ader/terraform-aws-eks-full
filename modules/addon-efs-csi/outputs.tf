output "role_arn" {
  description = "IAM Role for EFS CSI add-on arn"
  value       = aws_iam_role.this.arn
}

output "arn" {
  description = "EFS CSI add-on arn"
  value       = aws_eks_addon.this.arn
}

output "version" {
  description = "EFS CSI add-on version"
  value       = aws_eks_addon.this.addon_version
}
