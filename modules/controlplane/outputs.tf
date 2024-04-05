
output "name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "arn" {
  description = "EKS cluster arn"
  value       = aws_eks_cluster.main.arn
}

output "version" {
  description = "EKS cluster current version"
  value       = aws_eks_cluster.main.version
}
output "oidc_provider" {
  description = "EKS cluster OIDC provider params"
  value       = aws_iam_openid_connect_provider.main
}

output "ca_cert" {
  description = "EKS cluster CA Certificate"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "endpoint" {
  description = "EKS cluster endpoint connection URL"
  value       = aws_eks_cluster.main.endpoint
}

output "security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "custom_security_group_id" {
  description = "EKS cluster additional Security group ID"
  value       = aws_eks_cluster.main.vpc_config[0].security_group_ids
}
output "kubeconfig_update_cmd" {
  description = "kubectl config command"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.id} --region ${var.current_region}"
}
