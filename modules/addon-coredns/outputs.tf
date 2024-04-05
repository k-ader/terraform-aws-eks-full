output "arn" {
  description = "Core DNS add-on arn"
  value       = aws_eks_addon.coredns.arn
}

output "version" {
  description = "Core DNS add-on pversion"
  value       = aws_eks_addon.coredns.addon_version
}
