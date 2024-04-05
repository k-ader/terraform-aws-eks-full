##### IAM Role
resource "aws_iam_role" "vpc_cni_addon" {
  name = "${var.eks_name}-AmazonEKS_VPC_CNI_Role"
  assume_role_policy = templatefile("${path.module}/../../files/role_assume_sa.json.tpl",
    {
      oidc_provider_arn = var.oidc_provider_arn
      oidc_provider_url = replace(var.oidc_provider_arn, "/^(.*provider/)/", "")
      namespace         = "kube-system"
      service_account   = "aws-node"
    }
  )
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  max_session_duration = "3600"
  path                 = "/"

  tags = var.tags
}

##### VPC-CNI
data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.eks_version
  most_recent        = var.latest_addon_version
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = var.eks_name
  addon_name                  = "vpc-cni"
  addon_version               = data.aws_eks_addon_version.vpc_cni.version
  resolve_conflicts_on_update = var.resolve_conflicts_on_update
  resolve_conflicts_on_create = var.resolve_conflicts_on_create
  service_account_role_arn    = aws_iam_role.vpc_cni_addon.arn
  preserve                    = true
  configuration_values = length(var.pod_subnet_ids) == 0 ? null : jsonencode({
    env = {
      AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
      ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
    }
  })

  tags = var.tags
}


### Move to separate_conf? <EOF
data "aws_subnet" "pod_networks" {
  for_each = toset(var.pod_subnet_ids)
  id       = each.key
}

resource "kubernetes_manifest" "eniconfig" {
  for_each = var.eniconfig_create ? data.aws_subnet.pod_networks : {}
  #   provider = kubernetes
  manifest = {
    apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
    kind       = "ENIConfig"
    metadata = {
      name = each.value["availability_zone"]
    }
    spec = {
      subnet         = each.value["id"]
      securityGroups = [var.eks_security_group_id]
    }
  }
  depends_on = [aws_eks_addon.vpc_cni]
}
# EOF
