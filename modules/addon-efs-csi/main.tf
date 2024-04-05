##### IAM Role
resource "aws_iam_role" "this" {
  name = "${var.eks_name}-AmazonEKS_EFS_CSI_DriverRole"
  assume_role_policy = templatefile("${path.module}/../../files/role_assume_sa.json.tpl",
    {
      oidc_provider_arn = var.oidc_provider_arn
      oidc_provider_url = replace(var.oidc_provider_arn, "/^(.*provider/)/", "")
      namespace         = "kube-system"
      service_account   = "efs-csi-*"
    }
  )
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"]
  max_session_duration = "3600"
  path                 = "/"

  tags = var.tags
}

##### EFS CSI
data "aws_eks_addon_version" "latest" {
  addon_name         = "aws-efs-csi-driver"
  kubernetes_version = var.eks_version
  most_recent        = var.latest_addon_version
}

resource "aws_eks_addon" "this" {
  cluster_name                = var.eks_name
  addon_name                  = "aws-efs-csi-driver"
  addon_version               = data.aws_eks_addon_version.latest.version
  resolve_conflicts_on_update = var.resolve_conflicts_on_update
  resolve_conflicts_on_create = var.resolve_conflicts_on_create
  service_account_role_arn    = aws_iam_role.this.arn

  tags = var.tags
}
