data "aws_vpc" "eks" {
  id = var.vpc_id
}

data "tls_certificate" "main" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
