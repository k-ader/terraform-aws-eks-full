###### IAM Role
resource "aws_iam_role" "ebs_csi" {
  name = "${var.eks_name}-AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = templatefile("${path.module}/../../files/role_assume_aud.json.tpl",
    {
      oidc_provider_arn = var.oidc_provider_arn
      oidc_provider_url = replace(var.oidc_provider_arn, "/^(.*provider/)/", "")
    }
  )
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  max_session_duration = "3600"
  path                 = "/"
  tags                 = var.tags
}

##### EBS CSI
data "aws_eks_addon_version" "latest" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.eks_version
  most_recent        = var.latest_addon_version
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name                = var.eks_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = data.aws_eks_addon_version.latest.version
  resolve_conflicts_on_update = var.resolve_conflicts_on_update
  resolve_conflicts_on_create = var.resolve_conflicts_on_create
  service_account_role_arn    = aws_iam_role.ebs_csi.arn

  tags = var.tags
}

# TODO skip in case of default KMS key
#resource "aws_kms_grant" "vpc_cni" {
#  grantee_principal = aws_iam_role.ebs_csi.arn
#  key_id            = var.kms_ebs_key_id
#  operations = [
#    "Encrypt",
#    "Decrypt",
#    "GenerateDataKey",
#    "DescribeKey",
#    "CreateGrant"
#  ]
#}
