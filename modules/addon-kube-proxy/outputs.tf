output "arn" {
  description = "Kube proxy add-on arn"
  value       = aws_eks_addon.kube_proxy.arn
}

output "version" {
  description = "Kube proxy add-on version"
  value       = aws_eks_addon.kube_proxy.addon_version
}
